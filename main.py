"""
Artisan Marketplace API: FastAPI backend running on Google Cloud.

Authentication note:
    verify_identity_token() below fully implements Google Identity Platform
    token verification, but auth was switched off for the hackathon demo, so
    every route currently acts as DEMO_UID. To turn it on for a route, import
    `Depends` from fastapi, add `claims: dict = Depends(verify_identity_token)`
    to the route's parameters, and use claims["uid"] instead of DEMO_UID.
"""
import base64
import datetime as dt
import json
import logging
import os
from collections import Counter
from typing import Annotated, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, File, Header, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from google.auth.transport import requests as ga_requests
from google.cloud import aiplatform, firestore, speech, storage
from google.oauth2 import id_token as ga_id_token
from pydantic import BaseModel
from vertexai import init as vertex_init
from vertexai.generative_models import GenerativeModel
from vertexai.preview.vision_models import Image as VtxImage
from vertexai.preview.vision_models import ImageGenerationModel

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("artisan-api")

PROJECT_ID = os.getenv("PROJECT_ID")
LOCATION = os.getenv("LOCATION", "us-central1")
GOOGLE_APPLICATION_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
BUCKET_NAME = os.getenv("BUCKET_NAME")

if not PROJECT_ID or not GOOGLE_APPLICATION_CREDENTIALS:
    raise RuntimeError("Missing PROJECT_ID or GOOGLE_APPLICATION_CREDENTIALS in .env")

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = GOOGLE_APPLICATION_CREDENTIALS

# ---------------------------------------------------------------------------
# Google Cloud clients
# ---------------------------------------------------------------------------
db = firestore.Client(project=PROJECT_ID)
storage_client = storage.Client(project=PROJECT_ID)
bucket = storage_client.bucket(BUCKET_NAME)
if not bucket.exists():
    raise RuntimeError(
        f"GCS bucket '{BUCKET_NAME}' not found. Create it in Console or set the correct BUCKET_NAME."
    )

aiplatform.init(project=PROJECT_ID, location=LOCATION)
vertex_init(project=PROJECT_ID, location=LOCATION)

GEMINI_MODEL = GenerativeModel("gemini-2.0-flash")
speech_client = speech.SpeechClient()

STUDIO_PROMPT = (
    "Create a professional, high-end ecommerce product photo. Keep the product exactly as it is: "
    "preserve its true shape, proportions, textures, and exact colors. Do not add, remove, or modify "
    "any product details. Place it on a seamless, premium studio background with a smooth gradient "
    "from soft light gray (#f5f5f5) to pure white. Lighting should be bright, diffused, and evenly "
    "balanced, with no harsh reflections or color shifts. Add a very subtle, natural ground shadow "
    "directly under the product for depth. The final image should look like a luxury catalog photo: "
    "crisp, high resolution, minimalistic, with sharp focus and no noise, blemishes, or artifacts. "
    "Do not generate anything outside of the product itself and the clean background."
)

# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------
app = FastAPI(title="Artisan Marketplace API", version="3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # demo setting: restrict to the frontend's domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def verify_identity_token(authorization: Annotated[str | None, Header()] = None) -> dict:
    """
    Verifies a Google Identity Platform ID token.
    Clients must authenticate via Identity Platform (client SDK / REST) and send:
        Authorization: Bearer <ID_TOKEN>
    """
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    try:
        token = authorization.split(" ")[1]
    except Exception:
        raise HTTPException(status_code=401, detail="Malformed Authorization header")

    try:
        req = ga_requests.Request()
        claims = ga_id_token.verify_oauth2_token(token, req, audience=PROJECT_ID)
        iss_ok = claims.get("iss") in (
            f"https://securetoken.google.com/{PROJECT_ID}",
            "https://accounts.google.com",
            "accounts.google.com",
        )
        if not iss_ok:
            raise ValueError(f"Invalid issuer: {claims.get('iss')}")
        uid = claims.get("user_id") or claims.get("sub")
        if not uid:
            raise ValueError("Token missing user identifier")
        claims["uid"] = uid
        return claims
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {e}")


# Auth is disabled for the demo (see module docstring); every request acts as this user.
DEMO_UID = "demo-user"


class DescriptionIn(BaseModel):
    description: str
    title: Optional[str] = None
    language: Optional[str] = "en"
    category: Optional[str] = None


# ---------------------------------------------------------------------------
# Uploads
# ---------------------------------------------------------------------------
@app.post("/upload/image")
def upload_image(file: UploadFile = File(...)):
    try:
        uid = DEMO_UID
        object_name = f"{uid}/{dt.datetime.utcnow().strftime('%Y%m%dT%H%M%S')}_{file.filename}"
        blob = bucket.blob(object_name)
        blob.upload_from_file(file.file, content_type=file.content_type)
        # Demo only: the object is made public. Use signed URLs in production.
        blob.make_public()
        return {"message": "Image uploaded", "url": blob.public_url, "gcs_path": f"gs://{BUCKET_NAME}/{object_name}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image upload failed: {e}")


# ---------------------------------------------------------------------------
# Stats
# ---------------------------------------------------------------------------
def _daterange(n_days=30):
    today = dt.date.today()
    start = today - dt.timedelta(days=n_days)
    return start, today


@app.get("/stats/overview")
def stats_overview(days: int = 30):
    """
    Reads the 'orders' collection. Each order should include:
    items: [{product_id, qty, price_at_purchase}], owner_split: {artisan_uid: amount}, created_at
    """
    try:
        artisan_id = DEMO_UID
        start_date, _ = _daterange(days)
        start_ts = dt.datetime.combine(start_date, dt.time.min)

        q = db.collection("orders").where("created_at", ">=", start_ts)
        orders = [dict(doc.to_dict(), id=doc.id) for doc in q.stream()]
        orders = [o for o in orders if artisan_id in (o.get("owner_split") or {})]

        total_orders = len(orders)
        revenue = sum(o.get("owner_split", {}).get(artisan_id, 0.0) for o in orders)
        items_count = 0
        product_counter = Counter()
        for o in orders:
            for it in o.get("items", []):
                product_counter[it["product_id"]] += it["qty"]
                items_count += it["qty"]
        aov = (revenue / total_orders) if total_orders else 0.0
        top_products = [{"product_id": pid, "qty": qty} for pid, qty in product_counter.most_common(5)]

        products = []
        for doc in db.collection("products").where("owner_id", "==", artisan_id).stream():
            p = doc.to_dict()
            p["id"] = doc.id
            products.append(p)

        return {
            "days": days,
            "summary": {
                "total_orders": total_orders,
                "revenue": round(revenue, 2),
                "items_sold": items_count,
                "average_order_value": round(aov, 2),
                "top_products": top_products,
            },
            "catalog_size": len(products),
            "products": products,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Stats failed: {e}")


# ---------------------------------------------------------------------------
# AI features
# ---------------------------------------------------------------------------
@app.get("/ai/analysis")
def analysis_dashboard(days: int = 30):
    try:
        stats = stats_overview(days=days)
        prompt = {
            "task": "Marketplace coaching for Indian artisan",
            "context": {
                "stats": stats["summary"],
                "catalog_size": stats["catalog_size"],
                "products": stats["products"],
                "time_window_days": stats["days"],
            },
            "instructions": [
                "Return STRICT JSON with keys: 'pricing', 'bundles', 'seo', 'photos', 'seasonality', 'inventory', 'promotions', 'discounts', 'new_product_ideas'.",
                "Each key should be a list of recommendations; include rationale and expected impact.",
                "Consider Indian festivals (Diwali, Rakhi, Eid, wedding season) and payday patterns.",
            ],
        }
        resp = GEMINI_MODEL.generate_content(
            [json.dumps(prompt)],
            generation_config={"response_mime_type": "application/json"},
        )
        try:
            ai_json = json.loads(resp.text)
        except Exception:
            ai_json = {"raw": resp.text}
        return {"stats": stats, "ai": ai_json}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")


@app.post("/ai/enhance-description")
def enhance_description(body: DescriptionIn):
    try:
        prompt = {
            "task": "Enhance an artisan product listing for ecommerce in India",
            "inputs": body.dict(),
            "instructions": [
                "Return STRICT JSON with keys: title, short_description, long_description, bullet_points[], seo_tags[], alt_text.",
                "Tone: warm, authentic, concise; avoid hype.",
                "Include craft technique, materials, care instructions if present.",
                "Optimize title for search (<=70 chars) including craft terms (Banarasi, Ajrakh, Dhokra, etc.).",
                "Use Indian English if language='en'.",
            ],
        }
        resp = GEMINI_MODEL.generate_content(
            [json.dumps(prompt)],
            generation_config={"response_mime_type": "application/json"},
        )
        try:
            return json.loads(resp.text)
        except Exception:
            return {"raw": resp.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Enhancement failed: {e}")


@app.post("/ai/speech-to-pitch")
def speech_to_pitch(file: UploadFile = File(...)):
    try:
        audio_bytes = file.file.read()
        audio = speech.RecognitionAudio(content=audio_bytes)
        config = speech.RecognitionConfig(
            language_code="en-IN",  # adjust or expose as a query param
            enable_automatic_punctuation=True,
            model="latest_long",
        )
        stt_resp = speech_client.recognize(config=config, audio=audio)
        transcript = " ".join([r.alternatives[0].transcript for r in stt_resp.results]) if stt_resp.results else ""

        system_prompt = (
            "You are helping an Indian artisan craft a business pitch. "
            "Given a transcript, return strict JSON with keys: "
            "transcription, summary, pitch_title, pitch_story, key_points[]."
        )
        resp = GEMINI_MODEL.generate_content(
            [system_prompt, f"TRANSCRIPT:\n{transcript}\n\nNow produce the JSON."],
            generation_config={"response_mime_type": "application/json"},
        )
        try:
            out = json.loads(resp.text)
        except Exception:
            out = {"transcription": transcript, "raw": resp.text}
        return out
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Speech-to-pitch failed: {e}")


@app.post("/ai/clean-image")
def clean_image(file: UploadFile = File(...)):
    """
    Background removal + studio background using Vertex AI Imagen.
    Returns 2 base64 images:
      - transparent_png_base64: subject cutout
      - studio_background_base64: subject on a clean gradient
    """
    try:
        image_bytes = file.file.read()
        logger.info("clean-image: received %s (%d bytes)", file.filename, len(image_bytes))
        base = VtxImage(image_bytes=image_bytes)
        model = ImageGenerationModel.from_pretrained("imagegeneration@002")

        # Step 1: cut the product out of its background
        cutout_resp = model.edit_image(
            base_image=base,
            prompt="Remove the entire background; keep only the product with clean edges. Output PNG with transparent background.",
            guidance_scale=18,
        )
        cutout_img = cutout_resp[0] if isinstance(cutout_resp, list) else cutout_resp
        cutout_bytes = cutout_img.images[0]._image_bytes

        # Step 2: place the cutout on a studio background
        studio_resp = model.edit_image(
            base_image=VtxImage(image_bytes=cutout_bytes),
            prompt=STUDIO_PROMPT,
            guidance_scale=18,
        )
        studio_img = studio_resp[0] if isinstance(studio_resp, list) else studio_resp
        studio_bytes = studio_img.images[0]._image_bytes

        return {
            "transparent_png_base64": base64.b64encode(cutout_bytes).decode("utf-8"),
            "studio_background_base64": base64.b64encode(studio_bytes).decode("utf-8"),
            "mime": "image/png",
        }
    except Exception as e:
        logger.exception("Image cleaning failed")
        raise HTTPException(status_code=500, detail=f"Image cleaning failed: {e}")
