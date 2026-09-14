"""
Crop advisor backed by any OpenAI-compatible chat completions API.

Gemini, Groq, OpenRouter, Together, OpenAI and Ollama all speak the same
protocol, so the provider is a base URL and a model name rather than a
separate client class each. One code path, one SDK, one place to fail.
"""

import os
import re
from functools import lru_cache

from openai import OpenAI

# The UI renders answers as plain text, so markdown arrives as literal "**"
# on screen. Asking for plain text costs nothing and reads far better than
# stripping formatting afterwards.
#
# The word limit is the main lever on cost: output tokens dominate the bill,
# and a farmer reading on a phone wants the answer, not an essay.
SYSTEM_PROMPT = """You are an agricultural advisor for small-scale Sri Lankan farmers.

Write in plain text only. Never use markdown: no asterisks, no bold, no hash
headings, no bullet characters. For a list, start each line with a dash and a space.

Be brief. Answer in at most 110 words. Lead with the practical answer and skip
preamble. Use simple language and give costs in Sri Lankan Rupees (Rs.).

You know crop cultivation (rice, vegetables, fruits, tea, rubber), fertilizer
types and rates, pest and disease management, irrigation, harvest timing and
farm financial management."""

# A ceiling, not a reservation - billing is on tokens actually produced.
# Reasoning models such as Gemini 3.x spend part of this budget on internal
# thinking that is never returned, so a low ceiling truncates the visible
# answer mid-sentence. Brevity comes from the prompt above, not from here.
DEFAULT_MAX_TOKENS = 4096

# Cuts the hidden thinking budget on models that support it. Providers that
# do not understand the parameter reject the request, so it is dropped and
# retried once - see ask().
DEFAULT_REASONING_EFFORT = "low"

_MD_PATTERNS = [
    (re.compile(r"\*\*\*(.+?)\*\*\*", re.S), r"\1"),
    (re.compile(r"\*\*(.+?)\*\*", re.S), r"\1"),
    (re.compile(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", re.S), r"\1"),
    (re.compile(r"^\s{0,3}#{1,6}\s+", re.M), ""),
    (re.compile(r"^\s{0,3}[*+]\s+", re.M), "- "),
]


def base_url() -> str:
    return os.getenv("AI_BASE_URL", "").strip()


def model() -> str:
    return os.getenv("AI_MODEL", "").strip()


def is_configured() -> bool:
    return bool(os.getenv("AI_API_KEY", "").strip() and base_url() and model())


def _max_tokens() -> int:
    try:
        return int(os.getenv("AI_MAX_TOKENS", "").strip() or DEFAULT_MAX_TOKENS)
    except ValueError:
        return DEFAULT_MAX_TOKENS


def _reasoning_effort() -> str:
    # Blank disables the parameter entirely.
    return os.getenv("AI_REASONING_EFFORT", DEFAULT_REASONING_EFFORT).strip()


def _strip_markdown(text: str) -> str:
    """
    Safety net for when the model formats anyway.

    The prompt asks for plain text, but models drift, and a stray "**" in the
    UI looks broken. Cheaper and more reliable than rendering markdown here.
    """
    for pattern, replacement in _MD_PATTERNS:
        text = pattern.sub(replacement, text)
    return text.strip()


@lru_cache(maxsize=1)
def _client() -> OpenAI:
    """
    Built on first use, not at import.

    Constructing it at module level meant a missing key or an SDK mismatch
    took down the whole service at startup instead of failing the one request
    that needed it.
    """
    api_key = os.getenv("AI_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError("AI_API_KEY is not set. Add it to .env and restart ai-service.")
    if not base_url():
        raise RuntimeError("AI_BASE_URL is not set.")
    if not model():
        raise RuntimeError("AI_MODEL is not set.")
    return OpenAI(api_key=api_key, base_url=base_url(), timeout=90.0)


def ask(question: str, crop_context: str = "") -> str:
    system = SYSTEM_PROMPT
    if crop_context:
        system += f"\n\nThis farmer's crops: {crop_context}"

    kwargs = {
        "model": model(),
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": question},
        ],
        "temperature": 0.7,
        "max_tokens": _max_tokens(),
    }

    effort = _reasoning_effort()
    if effort:
        kwargs["reasoning_effort"] = effort

    try:
        response = _client().chat.completions.create(**kwargs)
    except Exception as e:
        # Providers without reasoning support reject the parameter outright.
        # Retrying once keeps this service genuinely provider-agnostic.
        if effort and "reasoning_effort" in str(e):
            kwargs.pop("reasoning_effort", None)
            try:
                response = _client().chat.completions.create(**kwargs)
            except Exception as retry_error:
                raise RuntimeError(f"AI request failed: {retry_error}") from retry_error
        else:
            raise RuntimeError(f"AI request failed: {e}") from e

    if not response.choices:
        raise RuntimeError("AI returned no choices")

    choice = response.choices[0]
    text = _strip_markdown(choice.message.content or "")

    if not text:
        # Safety filters return an empty message rather than an error; without
        # this the UI would show a silently blank answer.
        raise RuntimeError("AI returned an empty response (possibly filtered)")

    return text
