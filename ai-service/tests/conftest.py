"""
Shared fixtures. No test reaches a real model: the OpenAI client is replaced
with a fake that records what it was sent and replays scripted replies.
"""

from types import SimpleNamespace

import pytest

from services import advisor


def completion(text):
    """The shape of a chat completion, as much of it as advisor.py reads."""
    return SimpleNamespace(choices=[SimpleNamespace(message=SimpleNamespace(content=text))])


class FakeCompletions:
    def __init__(self, *replies):
        self.replies = list(replies)
        self.calls = []

    def create(self, **kwargs):
        self.calls.append(kwargs)
        reply = self.replies.pop(0)
        if isinstance(reply, Exception):
            raise reply
        return reply


@pytest.fixture(autouse=True)
def configured(monkeypatch):
    monkeypatch.setenv("AI_API_KEY", "test-key")
    monkeypatch.setenv("AI_BASE_URL", "https://example.invalid/v1/")
    monkeypatch.setenv("AI_MODEL", "test-model")
    monkeypatch.delenv("AI_REASONING_EFFORT", raising=False)
    monkeypatch.delenv("AI_MAX_TOKENS", raising=False)


@pytest.fixture
def fake_model(monkeypatch):
    """Install a fake client; call the returned function with the replies to script."""

    def install(*replies):
        completions = FakeCompletions(*replies)
        client = SimpleNamespace(chat=SimpleNamespace(completions=completions))
        monkeypatch.setattr(advisor, "_client", lambda: client)
        return completions

    return install
