"""Prompts sent to Gemini and Imagen."""

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

CUTOUT_PROMPT = ("Remove the entire background; keep only the product with clean edges. "
                 "Output PNG with transparent background.")


def coaching_prompt(stats: dict) -> dict:
    return {
        "task": "Marketplace coaching for Indian artisan",
        "context": {
            "stats": stats["summary"],
            "catalog_size": stats["catalog_size"],
            "products": stats["products"],
            "time_window_days": stats["days"],
        },
        "instructions": [
            "Return STRICT JSON with keys: 'pricing', 'bundles', 'seo', 'photos', 'seasonality', 'inventory', "
            "'promotions', 'discounts', 'new_product_ideas'.",
            "Each key should be a list of recommendations; include rationale and expected impact.",
            "Consider Indian festivals (Diwali, Rakhi, Eid, wedding season) and payday patterns.",
        ],
    }


def listing_prompt(inputs: dict) -> dict:
    return {
        "task": "Enhance an artisan product listing for ecommerce in India",
        "inputs": inputs,
        "instructions": [
            "Return STRICT JSON with keys: title, short_description, long_description, bullet_points[], seo_tags[], "
            "alt_text.",
            "Tone: warm, authentic, concise; avoid hype.",
            "Include craft technique, materials, care instructions if present.",
            "Optimize title for search (<=70 chars) including craft terms (Banarasi, Ajrakh, Dhokra, etc.).",
            "Use Indian English if language='en'.",
        ],
    }


PITCH_SYSTEM_PROMPT = (
    "You are helping an Indian artisan craft a business pitch. "
    "Given a transcript, return strict JSON with keys: "
    "transcription, summary, pitch_title, pitch_story, key_points[]."
)
