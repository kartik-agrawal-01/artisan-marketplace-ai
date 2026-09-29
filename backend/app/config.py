"""Settings, read from the environment (and a .env file in the working directory)."""
import os
from dataclasses import dataclass
from functools import lru_cache

from dotenv import load_dotenv


@dataclass(frozen=True)
class Settings:
    project_id: str | None
    location: str
    bucket_name: str | None
    credentials_path: str | None
    fake_cloud: bool

    def validate(self) -> None:
        """Fail fast with a clear message when the real Google Cloud backends are misconfigured."""
        if self.fake_cloud:
            return
        missing = [name for name, value in (("PROJECT_ID", self.project_id), ("BUCKET_NAME", self.bucket_name))
                   if not value]
        if missing:
            raise RuntimeError(f"Missing {', '.join(missing)} in the environment (see backend/.env.example), "
                               "or set ARTISAN_FAKE_CLOUD=1 to run with in-memory fakes.")
        if self.credentials_path and not os.path.exists(self.credentials_path):
            raise RuntimeError(f"GOOGLE_APPLICATION_CREDENTIALS points to a missing file: {self.credentials_path}")


@lru_cache
def get_settings() -> Settings:
    load_dotenv()
    return Settings(
        project_id=os.getenv("PROJECT_ID"),
        location=os.getenv("LOCATION", "us-central1"),
        bucket_name=os.getenv("BUCKET_NAME"),
        # Optional: on Cloud Run the service account's Application Default Credentials are used instead.
        credentials_path=os.getenv("GOOGLE_APPLICATION_CREDENTIALS"),
        fake_cloud=os.getenv("ARTISAN_FAKE_CLOUD", "").strip().lower() in {"1", "true", "yes"},
    )
