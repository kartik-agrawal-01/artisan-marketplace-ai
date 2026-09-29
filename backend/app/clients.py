"""Thin wrappers around the Google Cloud clients, provided to the routes as FastAPI dependencies.

Each wrapper exposes only what the API needs, so tests (and ARTISAN_FAKE_CLOUD=1 local runs) can swap in the
in-memory fakes from fakes.py. The Google libraries are imported lazily, on first use.
"""
import datetime as dt
from functools import lru_cache

from .config import get_settings

GEMINI_MODEL_NAME = "gemini-2.0-flash"
IMAGEN_MODEL_NAME = "imagegeneration@002"


class GcsStorage:
    def __init__(self, project_id, bucket_name):
        from google.cloud import storage

        self.bucket_name = bucket_name
        self.bucket = storage.Client(project=project_id).bucket(bucket_name)

    def check(self):
        if not self.bucket.exists():
            raise RuntimeError(f"GCS bucket '{self.bucket_name}' not found. Create it in Console or set the "
                               "correct BUCKET_NAME.")

    def upload_public(self, object_name: str, data: bytes, content_type: str) -> tuple[str, str]:
        """Upload and make the object public (demo only; use signed URLs in production)."""
        blob = self.bucket.blob(object_name)
        blob.upload_from_string(data, content_type=content_type)
        blob.make_public()
        return blob.public_url, f"gs://{self.bucket_name}/{object_name}"


class FirestoreStore:
    def __init__(self, project_id):
        from google.cloud import firestore

        self.db = firestore.Client(project=project_id)

    def orders_since(self, start: dt.datetime) -> list[dict]:
        q = self.db.collection("orders").where("created_at", ">=", start)
        return [dict(doc.to_dict(), id=doc.id) for doc in q.stream()]

    def products_of(self, owner_id: str) -> list[dict]:
        return [dict(doc.to_dict(), id=doc.id)
                for doc in self.db.collection("products").where("owner_id", "==", owner_id).stream()]


class GeminiJson:
    def __init__(self, project_id, location):
        from google.cloud import aiplatform
        from vertexai import init as vertex_init
        from vertexai.generative_models import GenerativeModel

        aiplatform.init(project=project_id, location=location)
        vertex_init(project=project_id, location=location)
        self.model = GenerativeModel(GEMINI_MODEL_NAME)

    def generate(self, parts: list[str]) -> str:
        """Ask Gemini for a JSON response; returns the raw text."""
        resp = self.model.generate_content(parts, generation_config={"response_mime_type": "application/json"})
        return resp.text


class SpeechTranscriber:
    def __init__(self):
        from google.cloud import speech

        self.speech = speech
        self.client = speech.SpeechClient()

    def transcribe(self, audio_bytes: bytes, language_code: str = "en-IN") -> str:
        audio = self.speech.RecognitionAudio(content=audio_bytes)
        config = self.speech.RecognitionConfig(language_code=language_code, enable_automatic_punctuation=True,
                                               model="latest_long")
        resp = self.client.recognize(config=config, audio=audio)
        return " ".join(r.alternatives[0].transcript for r in resp.results) if resp.results else ""


class ImagenEditor:
    def __init__(self, project_id, location):
        from vertexai import init as vertex_init
        from vertexai.preview.vision_models import Image, ImageGenerationModel

        vertex_init(project=project_id, location=location)
        self.Image = Image
        self.model = ImageGenerationModel.from_pretrained(IMAGEN_MODEL_NAME)

    def edit(self, image_bytes: bytes, prompt: str, guidance_scale: int = 18) -> bytes:
        resp = self.model.edit_image(base_image=self.Image(image_bytes=image_bytes), prompt=prompt,
                                     guidance_scale=guidance_scale)
        img = resp[0] if isinstance(resp, list) else resp
        return img.images[0]._image_bytes


def _fakes():
    from . import fakes
    return fakes.shared()


@lru_cache
def get_storage():
    s = get_settings()
    return _fakes().storage if s.fake_cloud else GcsStorage(s.project_id, s.bucket_name)


@lru_cache
def get_store():
    s = get_settings()
    return _fakes().store if s.fake_cloud else FirestoreStore(s.project_id)


@lru_cache
def get_llm():
    s = get_settings()
    return _fakes().llm if s.fake_cloud else GeminiJson(s.project_id, s.location)


@lru_cache
def get_transcriber():
    s = get_settings()
    return _fakes().transcriber if s.fake_cloud else SpeechTranscriber()


@lru_cache
def get_image_editor():
    s = get_settings()
    return _fakes().image_editor if s.fake_cloud else ImagenEditor(s.project_id, s.location)
