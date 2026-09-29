"""Artisan Marketplace API: FastAPI backend running on Google Cloud.

Run locally:
    ARTISAN_FAKE_CLOUD=1 uvicorn app.main:app --reload     # in-memory fakes, no GCP project needed
    uvicorn app.main:app --reload                           # real GCP project (see .env.example)

Authentication is switched off for the hackathon demo; see app/auth.py.
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .clients import get_storage
from .config import get_settings
from .routers import ai, stats, uploads

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("artisan-api")


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    settings.validate()
    if settings.fake_cloud:
        logger.warning("ARTISAN_FAKE_CLOUD=1: using in-memory fakes, no Google Cloud calls are made.")
    else:
        get_storage().check()  # fail fast if the bucket doesn't exist
    yield


def create_app() -> FastAPI:
    app = FastAPI(title="Artisan Marketplace API", version="3.1", lifespan=lifespan)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # demo setting: restrict to the frontend's domain in production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(uploads.router)
    app.include_router(stats.router)
    app.include_router(ai.router)

    @app.get("/healthz", tags=["health"])
    def healthz():
        return {"status": "ok", "fake_cloud": get_settings().fake_cloud}

    return app


app = create_app()
