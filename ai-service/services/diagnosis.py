"""
Crop doctor: a likely diagnosis from one photo of a plant.

The model is asked for strict JSON, but nothing it returns is trusted as-is.
Every field is coerced, clamped and length-limited here, so the backend and
the apps can rely on the shape whatever the model actually produced.
"""

import json
import os
import re
from typing import Literal

from pydantic import BaseModel, Field, field_validator, model_validator

from services import advisor

PROMPT = """You are a plant pathologist helping small-scale farmers in Sri Lanka.

Look at the photo. Reply with ONLY a JSON object, no other text, in exactly this shape:
{
  "isPlant": true,
  "cropGuess": "what crop this appears to be",
  "condition": "the most likely disease, pest or nutrient deficiency, or Healthy",
  "confidence": 0.0,
  "severity": "none | low | moderate | severe",
  "symptoms": ["what in the photo points to this"],
  "treatmentOrganic": ["practical organic or cultural treatment"],
  "treatmentChemical": ["chemical option by active ingredient, used as the label directs"],
  "prevention": ["how to stop it happening again"],
  "seeExpert": false
}

Rules:
- If the photo is not a plant, or is too blurred or dark to judge, set isPlant to false.
- confidence is your honest probability between 0 and 1. If it is below 0.5, set seeExpert to true.
- Set seeExpert to true for anything severe or likely to spread to neighbouring fields.
- At most 4 symptoms and at most 3 items in each other list. Each item under 20 words.
- Plain words a farmer understands. Methods and inputs available in Sri Lanka.
- Never name brands. Chemical advice by active ingredient only.
- For a healthy plant, use condition "Healthy", severity "none" and empty treatment lists."""

MAX_IMAGE_BYTES = 6 * 1024 * 1024

Severity = Literal["none", "low", "moderate", "severe"]


def vision_model() -> str:
    """A separate model for images when set; the chat model otherwise."""
    return os.getenv("AI_VISION_MODEL", "").strip() or advisor.model()


class Diagnosis(BaseModel):
    """The validated shape. Anything the model omits gets a safe default."""

    isPlant: bool = True
    cropGuess: str = ""
    condition: str = "Unknown"
    confidence: float = 0.0
    severity: Severity = "moderate"
    symptoms: list[str] = Field(default_factory=list)
    treatmentOrganic: list[str] = Field(default_factory=list)
    treatmentChemical: list[str] = Field(default_factory=list)
    prevention: list[str] = Field(default_factory=list)
    seeExpert: bool = False

    @field_validator("confidence", mode="before")
    @classmethod
    def _clamp_confidence(cls, value):
        try:
            number = float(value)
        except (TypeError, ValueError):
            return 0.0
        # Some models answer in percent.
        if number > 1:
            number = number / 100
        return max(0.0, min(1.0, number))

    @field_validator("severity", mode="before")
    @classmethod
    def _known_severity(cls, value):
        text = str(value or "").strip().lower()
        return text if text in ("none", "low", "moderate", "severe") else "moderate"

    @field_validator("cropGuess", "condition", mode="before")
    @classmethod
    def _short_text(cls, value):
        return str(value or "").strip()[:100]

    @field_validator("symptoms", "treatmentOrganic", "treatmentChemical", "prevention", mode="before")
    @classmethod
    def _short_list(cls, value):
        if isinstance(value, str):
            value = [value]
        if not isinstance(value, list):
            return []
        items = [str(item).strip()[:200] for item in value if str(item or "").strip()]
        return items[:4]

    @model_validator(mode="after")
    def _apply_rules(self):
        # The prompt asks for these; they are enforced here regardless.
        if not self.condition:
            self.condition = "Unknown"
        self.treatmentOrganic = self.treatmentOrganic[:3]
        self.treatmentChemical = self.treatmentChemical[:3]
        self.prevention = self.prevention[:3]
        if not self.isPlant:
            # Nothing to treat and no one to refer to: the answer is "retake it".
            self.condition = "Not a plant"
            self.severity = "none"
            self.seeExpert = False
            self.treatmentOrganic, self.treatmentChemical, self.prevention = [], [], []
        elif self.confidence < 0.5 or self.severity == "severe":
            # A guess, or something serious: a person should look at it.
            self.seeExpert = True
        return self


_JSON_OBJECT = re.compile(r"\{.*\}", re.S)


def parse(text: str) -> Diagnosis:
    """
    The model's reply as a Diagnosis. Tolerates the usual drift: a ```json
    fence, a sentence before or after the object.
    """
    if not text or not text.strip():
        raise RuntimeError("AI returned an empty diagnosis")
    candidates = [text.strip()]
    match = _JSON_OBJECT.search(text)
    if match:
        candidates.append(match.group(0))
    for candidate in candidates:
        try:
            data = json.loads(candidate)
        except json.JSONDecodeError:
            continue
        if isinstance(data, dict):
            return Diagnosis.model_validate(data)
    raise RuntimeError("AI returned a diagnosis that could not be read")


def diagnose(image_base64: str, mime_type: str = "image/jpeg", crop_hint: str = "") -> Diagnosis:
    if not image_base64:
        raise ValueError("No image was sent")
    if len(image_base64) * 3 // 4 > MAX_IMAGE_BYTES:
        raise ValueError("Image is too large")
    if mime_type not in ("image/jpeg", "image/png"):
        raise ValueError("Only JPEG and PNG images are supported")

    hint = (
        f"The farmer says this is {crop_hint.strip()[:100]}."
        if crop_hint and crop_hint.strip()
        else "The farmer did not say which crop this is."
    )
    kwargs = {
        "model": vision_model(),
        "messages": [
            {"role": "system", "content": PROMPT},
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": hint},
                    {"type": "image_url", "image_url": {"url": f"data:{mime_type};base64,{image_base64}"}},
                ],
            },
        ],
        "temperature": 0.2,
        "max_tokens": advisor._max_tokens(),
        "response_format": {"type": "json_object"},
    }
    effort = advisor._reasoning_effort()
    if effort:
        kwargs["reasoning_effort"] = effort

    response = _create(kwargs)
    if not response.choices:
        raise RuntimeError("AI returned no choices")
    return parse(response.choices[0].message.content or "")


def _create(kwargs: dict):
    """
    Calls the model, dropping optional parameters the provider rejects.
    Not every OpenAI-compatible provider supports JSON mode or reasoning
    effort; each is removed and retried once rather than failing the photo.
    """
    for _ in range(3):
        try:
            return advisor._client().chat.completions.create(**kwargs)
        # Broad on purpose: each provider SDK raises its own exception types.
        except Exception as e:
            message = str(e)
            dropped = [p for p in ("response_format", "reasoning_effort") if p in kwargs and p in message]
            if not dropped:
                raise RuntimeError(f"AI request failed: {e}") from e
            for param in dropped:
                kwargs.pop(param)
    raise RuntimeError("AI request failed after removing unsupported options")
