"""
Shopping mode demo — simulates price comparison use case.
No API calls needed: demonstrates the price-per-kg/L calculation logic
that will live in the app's domain layer.

Use case: user saves same product from different stores and compares value.

Usage:
    python shopping_demo.py
"""

from dataclasses import dataclass


@dataclass
class ShoppingItem:
    product_name: str
    store: str
    price: float        # in euros
    quantity: float     # numeric value
    unit: str           # "g" | "ml" | "kg" | "L"

    @property
    def price_per_kg_or_l(self) -> float:
        """Normalise to price per kg or per litre."""
        if self.unit in ("g", "ml"):
            return (self.price / self.quantity) * 1000
        elif self.unit in ("kg", "L"):
            return self.price / self.quantity
        raise ValueError(f"Unknown unit: {self.unit}")

    @property
    def unit_label(self) -> str:
        return "kg" if self.unit in ("g", "kg") else "L"


def compare_items(items: list[ShoppingItem]):
    print(f"\n{'='*60}")
    print(f"Product: {items[0].product_name}")
    print(f"{'='*60}")
    print(f"  {'Store':<18} {'Price':>7}  {'Qty':>10}  {'Per kg/L':>10}")
    print(f"  {'-'*18}  {'-'*7}  {'-'*10}  {'-'*10}")

    sorted_items = sorted(items, key=lambda x: x.price_per_kg_or_l)

    for i, item in enumerate(sorted_items):
        marker = " ← best value" if i == 0 else ""
        label = item.unit_label
        print(
            f"  {item.store:<18}  €{item.price:>5.2f}  "
            f"{item.quantity:>7g}{item.unit:<3}  "
            f"€{item.price_per_kg_or_l:>7.2f}/{label}{marker}"
        )
    print()


# ── Demo scenarios ─────────────────────────────────────────────────────────────

if __name__ == "__main__":

    # Scenario 1: olive oil across stores
    compare_items([
        ShoppingItem("Olive Oil (Extra Virgin)", "Continente",  3.49, 750,  "ml"),
        ShoppingItem("Olive Oil (Extra Virgin)", "Pingo Doce",  2.99, 500,  "ml"),
        ShoppingItem("Olive Oil (Extra Virgin)", "Aldi",        5.79, 1,    "L"),
        ShoppingItem("Olive Oil (Extra Virgin)", "Lidl",        4.49, 750,  "ml"),
    ])

    # Scenario 2: greek yogurt
    compare_items([
        ShoppingItem("Greek Yogurt (plain)",  "Continente",  1.29, 400, "g"),
        ShoppingItem("Greek Yogurt (plain)",  "Pingo Doce",  0.89, 250, "g"),
        ShoppingItem("Greek Yogurt (plain)",  "Aldi",        1.99, 1,   "kg"),
        ShoppingItem("Greek Yogurt (plain)",  "Lidl",        1.49, 500, "g"),
    ])

    # Scenario 3: pasta
    compare_items([
        ShoppingItem("Spaghetti (500g)",  "Continente",  0.79, 500, "g"),
        ShoppingItem("Spaghetti (1kg)",   "Pingo Doce",  1.39, 1,   "kg"),
        ShoppingItem("Spaghetti (500g)",  "Aldi",        0.59, 500, "g"),
    ])

    # Scenario 4: orange juice
    compare_items([
        ShoppingItem("Orange Juice",  "Continente",  1.99, 1,    "L"),
        ShoppingItem("Orange Juice",  "Pingo Doce",  2.49, 1.5,  "L"),
        ShoppingItem("Orange Juice",  "Aldi",        0.79, 500,  "ml"),
    ])
