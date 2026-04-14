"""
OpenFoodFacts — search products by name.
Use case: user types a product name to find it without scanning.

Usage:
    python off_search.py
    python off_search.py "greek yogurt"
"""

import sys
import requests

BASE_URL = "https://world.openfoodfacts.org"
FIELDS = "code,product_name,brands,quantity,image_url,nutriments"
HEADERS = {"User-Agent": "NutritionApp-Demo/1.0"}


def search_products(query: str, page_size: int = 5) -> list[dict]:
    url = f"{BASE_URL}/cgi/search.pl"
    params = {
        "search_terms": query,
        "json": 1,
        "page_size": page_size,
        "fields": FIELDS,
    }
    resp = requests.get(url, params=params, headers=HEADERS, timeout=10)
    resp.raise_for_status()
    return resp.json().get("products", [])


def print_result(i: int, product: dict):
    n = product.get("nutriments", {})
    kcal = n.get("energy-kcal_100g", "—")
    protein = n.get("proteins_100g", "—")
    carbs = n.get("carbohydrates_100g", "—")
    fat = n.get("fat_100g", "—")

    name = product.get("product_name") or "Unknown"
    brand = product.get("brands") or "—"
    quantity = product.get("quantity") or "—"
    barcode = product.get("code") or "—"

    print(f"  {i}. {name} — {brand} ({quantity})")
    print(f"     Barcode : {barcode}")
    print(f"     Macros  : {kcal} kcal | {protein}g protein | {carbs}g carbs | {fat}g fat")


SEARCH_DEMOS = [
    "greek yogurt",
    "whole grain bread",
    "dark chocolate",
    "peanut butter",
    "orange juice",
]


if __name__ == "__main__":
    queries = sys.argv[1:] or SEARCH_DEMOS

    for query in queries:
        print(f"\n{'='*52}")
        print(f"Search: '{query}'")
        print(f"{'='*52}")
        try:
            results = search_products(query, page_size=5)
            if results:
                for i, product in enumerate(results, 1):
                    print_result(i, product)
            else:
                print("  No results found.")
        except requests.RequestException as e:
            print(f"  Network error: {e}")
