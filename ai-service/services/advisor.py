"""
Crop advisor backed by any OpenAI-compatible chat completions API.

Gemini, Groq, OpenRouter, Together, OpenAI and Ollama all speak the same
protocol, so the provider is a base URL and a model name rather than a
separate client class each. One code path, one SDK, one place to fail.
"""

import os
from functools import lru_cache

from openai import OpenAI

SYSTEM_PROMPT = """You are an expert agricultural advisor for Sri Lankan farmers.
You have deep knowledge about:
- Crop cultivation (rice, vegetables, fruits, tea, rubber)
- Fertilizer types and application rates
- Pest and disease management
- Irrigation techniques
- Harvest timing and post-harvest handling
- Farm financial management and profit optimization

Always give practical, actionable advice suitable for small-scale farmers.
Keep responses clear and concise. Use simple language.
When discussing costs, use Sri Lankan Rupees (Rs.)."""


def base_url() -> str:
    return os.getenv("AI_BASE_URL", "").strip()


def model() -> str:
    return os.getenv("AI_MODEL", "").strip()


def is_configured() -> bool:
    return bool(os.getenv("AI_API_KEY", "").strip() and base_url() and model())


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
    return OpenAI(api_key=api_key, base_url=base_url(), timeout=60.0)


def ask(question: str, crop_context: str = "") -> str:
    system = SYSTEM_PROMPT
    if crop_context:
        system += f"\n\nFarmer's crop context: {crop_context}"

    try:
        response = _client().chat.completions.create(
            model=model(),
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": question},
            ],
            temperature=0.7,
            max_tokens=1024,
        )
    except Exception as e:
        raise RuntimeError(f"AI request failed: {e}") from e

    if not response.choices:
        raise RuntimeError("AI returned no choices")

    text = (response.choices[0].message.content or "").strip()
    if not text:
        # Safety filters return an empty message rather than an error; without
        # this the UI would show a silently blank answer.
        raise RuntimeError("AI returned an empty response (possibly filtered)")
    return text
