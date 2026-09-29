# Cloud Run image for the Artisan Marketplace API.
#   gcloud run deploy artisan-api --source backend --region us-central1 \
#     --set-env-vars PROJECT_ID=<project>,BUCKET_NAME=<bucket>,LOCATION=us-central1
# On Cloud Run the service account's credentials are used; don't bake a key file into the image.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PORT=8080
WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

RUN useradd --create-home appuser
USER appuser

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
