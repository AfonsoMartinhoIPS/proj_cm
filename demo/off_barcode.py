"""
OpenFoodFacts — fetch product by barcode.
Use case: user scans a barcode in the app.

Also fetches generic foods (rice, chicken, etc.) via USDA FoodData Central
since those don't have universal barcodes.

Usage:
    python off_barcode.py
    python off_barcode.py 3017624010701
"""

import sys
import requests

# --- OpenFoodFacts ---
OFF_BASE = "https://world.openfoodfacts.org"
OFF_FIELDS = "product_name,brands,quantity,image_url,ingredients_text,nutriments"

# --- USDA FoodData Central ---
USDA_BASE = "https://api.nal.usda.gov/fdc/v1"
USDA_KEY = "DEMO_KEY"  # Replace with real key from https://fdc.nal.usda.gov/api-guide.html

HEADERS = {"User-Agent": "NutritionApp-Demo/1.0"}


# ── OpenFoodFacts ──────────────────────────────────────────────────────────────

def fetch_by_barcode(barcode: str) -> dict | None:
    url = f"{OFF_BASE}/api/v2/product/{barcode}.json"
    resp = requests.get(url, params={"fields": OFF_FIELDS}, headers=HEADERS, timeout=10)
    resp.raise_for_status()
    data = resp.json()
    return data["product"] if data.get("status") == 1 else None


def print_off_product(barcode: str, product: dict):
    n = product.get("nutriments", {})
    print(f"\n{'='*52}")
    print(f"[OpenFoodFacts] Barcode: {barcode}")
    print(f"Name       : {product.get('product_name') or 'Unknown'}")
    print(f"Brand      : {product.get('brands') or '—'}")
    print(f"Quantity   : {product.get('quantity') or '—'}")
    print(f"Image      : {product.get('image_url') or '—'}")
    _print_nutriments_off(n)
    ingredients = product.get("ingredients_text")
    if ingredients:
        preview = ingredients[:120] + "..." if len(ingredients) > 120 else ingredients
        print(f"Ingredients: {preview}")
    print(f"{'='*52}")


def _print_nutriments_off(n: dict):
    print(f"\n  --- Nutrition per 100g ---")
    print(f"  Calories   : {n.get('energy-kcal_100g', '—')} kcal")
    print(f"  Protein    : {n.get('proteins_100g', '—')} g")
    print(f"  Carbs      : {n.get('carbohydrates_100g', '—')} g")
    print(f"    Sugar    : {n.get('sugars_100g', '—')} g")
    print(f"  Fat        : {n.get('fat_100g', '—')} g")
    print(f"    Sat. fat : {n.get('saturated-fat_100g', '—')} g")
    print(f"  Fiber      : {n.get('fiber_100g', '—')} g")
    print(f"  Salt       : {n.get('salt_100g', '—')} g\n")


# ── USDA FoodData Central ──────────────────────────────────────────────────────

NUTRIENT_IDS = {
    1008: "Calories (kcal)",
    1003: "Protein (g)",
    1005: "Carbs (g)",
    2000: "Sugar (g)",
    1004: "Fat (g)",
    1258: "Sat. fat (g)",
    1079: "Fiber (g)",
    1093: "Sodium (mg)",
}


def fetch_usda(query: str, max_results: int = 3) -> list[dict]:
    url = f"{USDA_BASE}/foods/search"
    params = {
        "query": query,
        "api_key": USDA_KEY,
        "dataType": "Foundation,SR Legacy",
        "pageSize": max_results,
    }
    resp = requests.get(url, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("foods", [])


def print_usda_food(food: dict):
    nutrients = {n["nutrientId"]: n["value"] for n in food.get("foodNutrients", [])}
    print(f"\n{'='*52}")
    print(f"[USDA] {food.get('description', 'Unknown')}")
    print(f"FDC ID     : {food.get('fdcId')}")
    print(f"Type       : {food.get('dataType')}")
    print(f"\n  --- Nutrition per 100g ---")
    for nid, label in NUTRIENT_IDS.items():
        val = nutrients.get(nid, "—")
        print(f"  {label:<20}: {val}")
    print(f"{'='*52}")


# ── Demo ───────────────────────────────────────────────────────────────────────

BARCODE_DEMOS = [
    ("5449000000996", "Coca-Cola 330ml"),
    ("3017624010701", "Nutella 400g"),
    ("3046920029014", "Lindt Dark Chocolate 70%"),
    ("8076809513388", "Barilla Spaghetti n.5"),
    ("0000000000000", "Not found — error case"),
]

USDA_DEMOS = [
    "white rice cooked",
    "chicken breast roasted",
    "dark chocolate 70 percent",
    "avocado raw",
    "whole milk",
    "oats rolled",
]


if __name__ == "__main__":
    if sys.argv[1:]:
        # Single barcode passed as argument
        barcode = sys.argv[1]
        print(f"\nFetching barcode: {barcode} ...")
        try:
            product = fetch_by_barcode(barcode)
            if product:
                print_off_product(barcode, product)
            else:
                print(f"  Product not found.")
        except requests.RequestException as e:
            print(f"  Network error: {e}")
        sys.exit(0)

    # ── Barcode demos (packaged products) ──
    print("\n" + "━"*52)
    print("  PACKAGED PRODUCTS — OpenFoodFacts (barcode)")
    print("━"*52)

    for barcode, label in BARCODE_DEMOS:
        print(f"\nFetching: {label} ({barcode})")
        try:
            product = fetch_by_barcode(barcode)
            if product:
                print_off_product(barcode, product)
            else:
                print(f"  Product not found for barcode: {barcode}")
        except requests.RequestException as e:
            print(f"  Network error: {e}")

    # ── Generic food demos (no barcode — USDA) ──
    print("\n\n" + "━"*52)
    print("  GENERIC FOODS / INGREDIENTS — USDA FoodData Central")
    print("━"*52)

    for query in USDA_DEMOS:
        print(f"\nSearching: '{query}'")
        try:
            foods = fetch_usda(query, max_results=1)
            if foods:
                print_usda_food(foods[0])
            else:
                print(f"  No results for: {query}")
        except requests.RequestException as e:
            print(f"  Network error: {e}")
