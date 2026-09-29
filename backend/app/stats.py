"""Sales statistics for one artisan, computed from order and product records."""
import datetime as dt
from collections import Counter


def window_start(days: int, today: dt.date | None = None) -> dt.datetime:
    today = today or dt.date.today()
    return dt.datetime.combine(today - dt.timedelta(days=days), dt.time.min)


def summarize(orders: list[dict], products: list[dict], artisan_id: str, days: int) -> dict:
    """Orders must include items: [{product_id, qty, price_at_purchase}] and owner_split: {artisan_uid: amount}."""
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
    return {
        "days": days,
        "summary": {
            "total_orders": total_orders,
            "revenue": round(revenue, 2),
            "items_sold": items_count,
            "average_order_value": round(aov, 2),
            "top_products": [{"product_id": pid, "qty": qty} for pid, qty in product_counter.most_common(5)],
        },
        "catalog_size": len(products),
        "products": products,
    }
