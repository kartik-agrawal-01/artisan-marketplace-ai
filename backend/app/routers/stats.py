from fastapi import APIRouter, Depends, HTTPException, Query

from ..auth import DEMO_UID
from ..clients import get_store
from ..stats import summarize, window_start

router = APIRouter(tags=["stats"])

Days = Query(30, ge=1, le=365, description="Size of the time window, in days (1-365)")


def compute_stats(store, days: int) -> dict:
    try:
        artisan_id = DEMO_UID
        orders = store.orders_since(window_start(days))
        products = store.products_of(artisan_id)
        return summarize(orders, products, artisan_id, days)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Stats failed: {e}")


@router.get("/stats/overview")
def stats_overview(days: int = Days, store=Depends(get_store)):
    """Orders, revenue, items sold, average order value and top products for the demo artisan."""
    return compute_stats(store, days)
