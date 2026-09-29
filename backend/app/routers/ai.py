import base64
import json
import logging

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel, Field

from ..clients import get_image_editor, get_llm, get_store, get_transcriber
from ..files import AUDIO_TYPES, IMAGE_TYPES, MAX_AUDIO_BYTES, MAX_IMAGE_BYTES, read_checked
from ..prompts import CUTOUT_PROMPT, PITCH_SYSTEM_PROMPT, STUDIO_PROMPT, coaching_prompt, listing_prompt
from .stats import Days, compute_stats

logger = logging.getLogger("artisan-api")
router = APIRouter(prefix="/ai", tags=["ai"])


class DescriptionIn(BaseModel):
    description: str = Field(..., min_length=1, max_length=5000)
    title: str | None = Field(None, max_length=200)
    language: str | None = "en"
    category: str | None = Field(None, max_length=100)


def parse_json(text: str, fallback: dict | None = None) -> dict:
    """Gemini is asked for strict JSON; if it returns something else, pass the raw text through."""
    try:
        return json.loads(text)
    except Exception:
        return {**(fallback or {}), "raw": text}


@router.get("/analysis")
def analysis_dashboard(days: int = Days, store=Depends(get_store), llm=Depends(get_llm)):
    """Stats plus Gemini's coaching recommendations."""
    stats = compute_stats(store, days)
    try:
        text = llm.generate([json.dumps(coaching_prompt(stats), default=str)])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")
    return {"stats": stats, "ai": parse_json(text)}


@router.post("/enhance-description")
def enhance_description(body: DescriptionIn, llm=Depends(get_llm)):
    """Turn a rough description into an SEO-ready listing."""
    try:
        text = llm.generate([json.dumps(listing_prompt(body.model_dump()))])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Enhancement failed: {e}")
    return parse_json(text)


@router.post("/speech-to-pitch")
def speech_to_pitch(file: UploadFile = File(...), transcriber=Depends(get_transcriber), llm=Depends(get_llm)):
    """Transcribe a WAV or FLAC recording (max 10 MB, about a minute) and turn it into a sales pitch."""
    audio, _ = read_checked(file, AUDIO_TYPES, MAX_AUDIO_BYTES)
    try:
        transcript = transcriber.transcribe(audio, language_code="en-IN")
        text = llm.generate([PITCH_SYSTEM_PROMPT, f"TRANSCRIPT:\n{transcript}\n\nNow produce the JSON."])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Speech-to-pitch failed: {e}")
    return parse_json(text, fallback={"transcription": transcript})


@router.post("/clean-image")
def clean_image(file: UploadFile = File(...), editor=Depends(get_image_editor)):
    """Background removal plus a studio background with Imagen. Returns two base64 PNGs.

    - transparent_png_base64: the product cut out
    - studio_background_base64: the product on a clean gradient
    """
    image_bytes, _ = read_checked(file, IMAGE_TYPES, MAX_IMAGE_BYTES)
    logger.info("clean-image: received %s (%d bytes)", file.filename, len(image_bytes))
    try:
        cutout = editor.edit(image_bytes, CUTOUT_PROMPT, guidance_scale=18)
        studio = editor.edit(cutout, STUDIO_PROMPT, guidance_scale=18)
    except Exception as e:
        logger.exception("Image cleaning failed")
        raise HTTPException(status_code=500, detail=f"Image cleaning failed: {e}")
    return {
        "transparent_png_base64": base64.b64encode(cutout).decode("utf-8"),
        "studio_background_base64": base64.b64encode(studio).decode("utf-8"),
        "mime": "image/png",
    }
