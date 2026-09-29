"""Google Identity Platform token verification.

Auth was switched off for the hackathon demo, so every route currently acts as DEMO_UID. To turn it on for a
route, add ``claims: dict = Depends(verify_identity_token)`` to its parameters and use ``claims["uid"]`` instead
of DEMO_UID.
"""
from typing import Annotated

from fastapi import Header, HTTPException

from .config import get_settings

# Auth is disabled for the demo; every request acts as this user.
DEMO_UID = "demo-user"


def verify_identity_token(authorization: Annotated[str | None, Header()] = None) -> dict:
    """Verify ``Authorization: Bearer <ID_TOKEN>`` issued by Google Identity Platform and return its claims."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    try:
        token = authorization.split(" ")[1]
    except Exception:
        raise HTTPException(status_code=401, detail="Malformed Authorization header")

    project_id = get_settings().project_id
    try:
        from google.auth.transport import requests as ga_requests
        from google.oauth2 import id_token as ga_id_token

        claims = ga_id_token.verify_oauth2_token(token, ga_requests.Request(), audience=project_id)
        iss_ok = claims.get("iss") in (
            f"https://securetoken.google.com/{project_id}",
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
