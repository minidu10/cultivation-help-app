import pytest

from services import advisor
from tests.conftest import completion


class TestMarkdownStripping:
    def test_bold_and_italics_lose_their_markers(self):
        assert advisor._strip_markdown("Use **urea** at *tillering*") == "Use urea at tillering"

    def test_headings_lose_their_hashes(self):
        assert advisor._strip_markdown("## Fertilizer plan\nApply 50 kg") == "Fertilizer plan\nApply 50 kg"

    def test_star_bullets_become_dashes(self):
        assert advisor._strip_markdown("* first\n* second") == "- first\n- second"

    def test_arithmetic_is_left_alone(self):
        # A lone asterisk between numbers is multiplication, not emphasis.
        assert advisor._strip_markdown("2 * 3 bags") == "2 * 3 bags"


class TestConfiguration:
    def test_configured_when_key_url_and_model_are_set(self):
        assert advisor.is_configured()

    @pytest.mark.parametrize("missing", ["AI_API_KEY", "AI_BASE_URL", "AI_MODEL"])
    def test_not_configured_when_anything_is_missing(self, monkeypatch, missing):
        monkeypatch.delenv(missing)
        assert not advisor.is_configured()

    def test_invalid_max_tokens_falls_back_to_the_default(self, monkeypatch):
        monkeypatch.setenv("AI_MAX_TOKENS", "lots")
        assert advisor._max_tokens() == advisor.DEFAULT_MAX_TOKENS


class TestAsk:
    def test_sends_the_question_with_the_system_prompt(self, fake_model):
        model = fake_model(completion("Apply 50 kg urea per acre."))

        answer = advisor.ask("How much urea for paddy?")

        assert answer == "Apply 50 kg urea per acre."
        call = model.calls[0]
        assert call["model"] == "test-model"
        assert call["messages"][0]["role"] == "system"
        assert "Sri Lankan" in call["messages"][0]["content"]
        assert call["messages"][1] == {"role": "user", "content": "How much urea for paddy?"}

    def test_crop_context_is_added_to_the_system_prompt(self, fake_model):
        model = fake_model(completion("ok"))

        advisor.ask("Should I harvest?", crop_context="Paddy BG 300, 90 days old")

        assert "Paddy BG 300, 90 days old" in model.calls[0]["messages"][0]["content"]

    def test_asks_for_low_reasoning_effort_by_default(self, fake_model):
        model = fake_model(completion("ok"))

        advisor.ask("q")

        assert model.calls[0]["reasoning_effort"] == "low"

    def test_blank_reasoning_effort_leaves_the_parameter_out(self, fake_model, monkeypatch):
        monkeypatch.setenv("AI_REASONING_EFFORT", "")
        model = fake_model(completion("ok"))

        advisor.ask("q")

        assert "reasoning_effort" not in model.calls[0]

    def test_retries_without_reasoning_effort_when_the_provider_rejects_it(self, fake_model):
        model = fake_model(
            ValueError("Unrecognized request argument supplied: reasoning_effort"),
            completion("Second time lucky."),
        )

        assert advisor.ask("q") == "Second time lucky."
        assert "reasoning_effort" in model.calls[0]
        assert "reasoning_effort" not in model.calls[1]

    def test_other_provider_errors_are_not_retried(self, fake_model):
        model = fake_model(ConnectionError("network down"))

        with pytest.raises(RuntimeError, match="AI request failed"):
            advisor.ask("q")
        assert len(model.calls) == 1

    def test_markdown_in_the_answer_is_stripped(self, fake_model):
        fake_model(completion("**Water** early in the morning."))

        assert advisor.ask("q") == "Water early in the morning."

    def test_an_empty_answer_is_an_error_not_a_blank_reply(self, fake_model):
        # Safety filters return an empty message instead of raising.
        fake_model(completion(""))

        with pytest.raises(RuntimeError, match="empty response"):
            advisor.ask("q")

    def test_no_choices_is_an_error(self, fake_model):
        from types import SimpleNamespace

        fake_model(SimpleNamespace(choices=[]))

        with pytest.raises(RuntimeError, match="no choices"):
            advisor.ask("q")
