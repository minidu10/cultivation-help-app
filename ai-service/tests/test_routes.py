import pytest
from fastapi.testclient import TestClient

from main import app
from tests.conftest import completion


@pytest.fixture
def client():
    return TestClient(app)


def test_health_reports_the_model_and_configuration(client):
    body = client.get("/ai/health").json()

    assert body["status"] == "UP"
    assert body["model"] == "test-model"
    assert body["configured"] is True


def test_health_reports_missing_configuration(client, monkeypatch):
    monkeypatch.delenv("AI_API_KEY")

    assert client.get("/ai/health").json()["configured"] is False


def test_ask_returns_the_answer_and_the_model(client, fake_model):
    fake_model(completion("Drain the field two weeks before harvest."))

    response = client.post("/ai/ask", json={"question": "When do I drain paddy?"})

    assert response.status_code == 200
    assert response.json() == {"answer": "Drain the field two weeks before harvest.", "model": "test-model"}


def test_blank_question_is_rejected(client):
    assert client.post("/ai/ask", json={"question": "   "}).status_code == 400


def test_model_failure_is_503_so_the_backend_can_say_the_advisor_is_down(client, fake_model):
    fake_model(ConnectionError("provider unreachable"))

    assert client.post("/ai/ask", json={"question": "q"}).status_code == 503


def test_insights_prompt_carries_the_crop_figures(client, fake_model):
    model = fake_model(completion("Costs are high; switch to split fertilizer doses."))

    response = client.post("/ai/insights", json={
        "crop_name": "Big Onion",
        "total_expenses": 125000,
        "total_revenue": 98000.5,
        "net_profit": -26999.5,
        "status": "HARVESTED",
    })

    assert response.status_code == 200
    assert response.json()["crop"] == "Big Onion"
    prompt = model.calls[0]["messages"][1]["content"]
    assert "Big Onion" in prompt
    assert "Rs. 125,000.00" in prompt
    assert "Rs. -26,999.50" in prompt


def test_insights_rejects_missing_figures(client):
    assert client.post("/ai/insights", json={"crop_name": "Paddy"}).status_code == 422
