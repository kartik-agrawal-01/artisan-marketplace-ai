import datetime as dt

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from ..auth import DEMO_UID
from ..clients import get_storage
from ..files import IMAGE_TYPES, MAX_IMAGE_BYTES, read_checked, safe_filename

router = APIRouter(tags=["uploads"])


@router.post("/upload/image")
def upload_image(file: UploadFile = File(...), storage=Depends(get_storage)):
    """Upload a JPEG, PNG or WebP product image (max 10 MB) to Cloud Storage."""
    data, mime = read_checked(file, IMAGE_TYPES, MAX_IMAGE_BYTES)
    object_name = f"{DEMO_UID}/{dt.datetime.now(dt.UTC).strftime('%Y%m%dT%H%M%S')}_{safe_filename(file.filename)}"
    try:
        url, gcs_path = storage.upload_public(object_name, data, mime)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image upload failed: {e}")
    return {"message": "Image uploaded", "url": url, "gcs_path": gcs_path}
