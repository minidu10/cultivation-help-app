import json
from types import SimpleNamespace

import pytest
from fastapi.testclient import TestClient

from main import app
from services import diagnosis
from tests.conftest import FakeCompletions, completion

TINY_JPEG = "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQ=="  # any base64 will do; the model is fake

BLAST = {
    "isPlant": True,
    "cropGuess": "Rice",
    "condition": "Rice blast",
    "confidence": 0.82,
    "severity": "moderate",
    "symptoms": ["Diamond-shaped grey lesions with brown edges"],
    "treatmentOrganic": ["Remove and burn badly affected leaves"],
    "treatmentChemical": ["Tricyclazole, as the label directs"],
    "prevention": ["Avoid excess nitrogen", "Use resistant varieties such as BG 300"],
    "seeExpert": False,
}


@pytest.fixture
def client():
    return TestClient(app)


class TestParsing:
    def test_plain_json(self):
        result = diagnosis.parse(json.dumps(BLAST))

        assert result.condition == "Rice blast"
        assert result.confidence == pytest.approx(0.82)
        assert result.seeExpert is False

    def test_json_in_a_markdown_fence_with_chatter(self):
        text = "Here is my assessment:\n```json\n" + json.dumps(BLAST) + "\n```\nHope this helps!"

        assert diagnosis.parse(text).condition == "Rice blast"

    def test_unreadable_reply_is_an_error(self):
        with pytest.raises(RuntimeError, match="could not be read"):
            diagnosis.parse("I think it might be blast, not sure.")

    def test_empty_reply_is_an_error(self):
        with pytest.raises(RuntimeError, match="empty"):
            diagnosis.parse("   ")


class TestNormalising:
    """The model's output is coerced into a shape the apps can rely on."""

    def test_missing_fields_get_safe_defaults(self):
        result = diagnosis.parse("{}")

        assert result.condition == "Unknown"
        assert result.symptoms == []
        # Zero confidence is a guess, and a guess goes to an expert.
        assert result.seeExpert is True

    def test_percent_confidence_is_scaled(self):
        assert diagnosis.parse('{"confidence": 82}').confidence == pytest.approx(0.82)

    def test_confidence_is_clamped(self):
        assert diagnosis.parse('{"confidence": -3}').confidence == 0.0
        assert diagnosis.parse('{"confidence": "very high"}').confidence == 0.0

    def test_unknown_severity_becomes_moderate(self):
        assert diagnosis.parse('{"severity": "catastrophic", "confidence": 0.9}').severity == "moderate"

    def test_lists_are_capped(self):
        many = [f"step {i}" for i in range(10)]
        result = diagnosis.parse(json.dumps({**BLAST, "symptoms": many, "treatmentOrganic": many}))

        assert len(result.symptoms) == 4
        assert len(result.treatmentOrganic) == 3

    def test_a_single_string_becomes_a_list(self):
        assert diagnosis.parse('{"prevention": "Rotate crops"}').prevention == ["Rotate crops"]

    def test_low_confidence_always_recommends_an_expert(self):
        assert diagnosis.parse(json.dumps({**BLAST, "confidence": 0.3, "seeExpert": False})).seeExpert is True

    def test_severe_always_recommends_an_expert(self):
        severe = {**BLAST, "severity": "severe", "seeExpert": False}

        assert diagnosis.parse(json.dumps(severe)).seeExpert is True

    def test_not_a_plant_clears_the_advice(self):
        result = diagnosis.parse(json.dumps({**BLAST, "isPlant": False}))

        assert result.condition == "Not a plant"
        assert result.treatmentChemical == []
        assert result.seeExpert is False


class TestCallingTheModel:
    def test_sends_the_image_and_the_crop_hint(self, fake_model):
        model = fake_model(completion(json.dumps(BLAST)))

        diagnosis.diagnose(TINY_JPEG, "image/jpeg", "Paddy BG 300")

        call = model.calls[0]
        user = call["messages"][1]["content"]
        assert user[0]["text"] == "The farmer says this is Paddy BG 300."
        assert user[1]["image_url"]["url"].startswith("data:image/jpeg;base64,")
        assert call["response_format"] == {"type": "json_object"}

    def test_a_separate_vision_model_is_used_when_configured(self, fake_model, monkeypatch):
        monkeypatch.setenv("AI_VISION_MODEL", "vision-model")
        model = fake_model(completion(json.dumps(BLAST)))

        diagnosis.diagnose(TINY_JPEG)

        assert model.calls[0]["model"] == "vision-model"

    def test_drops_json_mode_when_the_provider_rejects_it(self, fake_model):
        model = fake_model(
            ValueError("Unsupported parameter: response_format"),
            completion(json.dumps(BLAST)),
        )

        assert diagnosis.diagnose(TINY_JPEG).condition == "Rice blast"
        assert "response_format" not in model.calls[1]

    def test_rejects_other_image_types(self):
        with pytest.raises(ValueError, match="JPEG and PNG"):
            diagnosis.diagnose(TINY_JPEG, "image/gif")


class TestVisionProvider:
    """Chat can stay on Groq while photos go to a provider with a vision model."""

    @pytest.fixture(autouse=True)
    def fresh_clients(self):
        # Clear the real cached client before and after. A test may have
        # swapped in a plain fake, which has no cache to clear.
        real = diagnosis._separate_client
        real.cache_clear()
        yield
        real.cache_clear()

    def test_photos_use_the_chat_client_when_no_vision_provider_is_set(self, fake_model):
        chat = fake_model(completion(json.dumps(BLAST)))

        diagnosis.diagnose(TINY_JPEG)

        assert len(chat.calls) == 1

    def test_photos_go_to_the_vision_provider_not_the_chat_one(self, fake_model, monkeypatch):
        monkeypatch.setenv("AI_VISION_BASE_URL", "https://vision.invalid/v1/")
        monkeypatch.setenv("AI_VISION_API_KEY", "vision-key")
        chat = fake_model()  # scripted with no replies: any call to it would fail
        vision = FakeCompletions(completion(json.dumps(BLAST)))
        monkeypatch.setattr(
            diagnosis, "_separate_client", lambda: SimpleNamespace(chat=SimpleNamespace(completions=vision))
        )

        assert diagnosis.diagnose(TINY_JPEG).condition == "Rice blast"
        assert len(vision.calls) == 1
        assert chat.calls == []

    def test_the_vision_client_is_built_from_the_vision_settings(self, monkeypatch):
        monkeypatch.setenv("AI_VISION_BASE_URL", "https://vision.invalid/v1/")
        monkeypatch.setenv("AI_VISION_API_KEY", "vision-key")

        client = diagnosis._client()

        assert str(client.base_url).startswith("https://vision.invalid/v1")
        assert client.api_key == "vision-key"

    def test_a_vision_url_alone_reuses_the_chat_key(self, monkeypatch):
        monkeypatch.setenv("AI_VISION_BASE_URL", "https://vision.invalid/v1/")
        monkeypatch.delenv("AI_VISION_API_KEY", raising=False)

        assert diagnosis._client().api_key == "test-key"

    def test_a_vision_key_alone_reuses_the_chat_url(self, monkeypatch):
        monkeypatch.setenv("AI_VISION_API_KEY", "vision-key")
        monkeypatch.delenv("AI_VISION_BASE_URL", raising=False)

        client = diagnosis._client()

        assert client.api_key == "vision-key"
        assert str(client.base_url).startswith("https://example.invalid/v1")


class TestRoute:
    def test_returns_the_diagnosis_and_the_model(self, client, fake_model):
        fake_model(completion(json.dumps(BLAST)))

        response = client.post("/ai/diagnose", json={"image_base64": TINY_JPEG, "crop_hint": "Paddy"})

        assert response.status_code == 200
        body = response.json()
        assert body["condition"] == "Rice blast"
        assert body["model"] == "test-model"

    def test_bad_input_is_400(self, client):
        assert client.post("/ai/diagnose", json={"image_base64": ""}).status_code == 400

    def test_model_failure_is_503(self, client, fake_model):
        fake_model(ConnectionError("down"))

        assert client.post("/ai/diagnose", json={"image_base64": TINY_JPEG}).status_code == 503

    def test_an_unreadable_answer_is_503(self, client, fake_model):
        fake_model(completion("Looks like blast to me."))

        assert client.post("/ai/diagnose", json={"image_base64": TINY_JPEG}).status_code == 503
