"""Upload checks: file type (from the file's first bytes, not the client's content type), size and name.

The Flutter app sends images as application/octet-stream, so the declared content type can't be trusted; the
checks look at the file signature instead.
"""
import re

from fastapi import HTTPException, UploadFile

MAX_IMAGE_BYTES = 10 * 1024 * 1024  # 10 MB
MAX_AUDIO_BYTES = 10 * 1024 * 1024  # Speech-to-Text's synchronous recognize() accepts at most 10 MB (about 1 minute)

IMAGE_TYPES = {"image/jpeg": "JPEG", "image/png": "PNG", "image/webp": "WebP"}
AUDIO_TYPES = {"audio/wav": "WAV", "audio/flac": "FLAC"}


def sniff_type(head: bytes) -> str | None:
    """MIME type from the file signature, for the formats the API accepts."""
    if head.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if head[:4] == b"RIFF" and head[8:12] == b"WEBP":
        return "image/webp"
    if head[:4] == b"RIFF" and head[8:12] == b"WAVE":
        return "audio/wav"
    if head.startswith(b"fLaC"):
        return "audio/flac"
    return None


def read_checked(file: UploadFile, allowed: dict[str, str], max_bytes: int) -> tuple[bytes, str]:
    """Read an upload, enforcing type and size. Returns (bytes, detected MIME type)."""
    data = file.file.read(max_bytes + 1)
    if not data:
        raise HTTPException(status_code=400, detail="The uploaded file is empty.")
    if len(data) > max_bytes:
        raise HTTPException(status_code=413,
                            detail=f"File too large: the limit is {max_bytes // (1024 * 1024)} MB.")
    mime = sniff_type(data[:16])
    if mime not in allowed:
        raise HTTPException(status_code=415,
                            detail=f"Unsupported file type. Upload {', '.join(allowed.values())}.")
    return data, mime


def safe_filename(name: str | None, default: str = "upload") -> str:
    """Keep only the base name and characters that are safe in a storage object path."""
    base = re.split(r"[\\/]", name or "")[-1]
    base = re.sub(r"[^A-Za-z0-9._-]+", "_", base).strip("._")
    return base[:100] or default
