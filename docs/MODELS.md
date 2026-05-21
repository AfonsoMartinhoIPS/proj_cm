# Data Models

Domain entities used across the app. These live in `lib/domain/entities/`.
Each model maps to either an API response (OpenFoodFacts / USDA) or a Firestore document.

---

## Product

Represents a food product — from barcode scan, search, or manual entry.

```dart
class Product {
  final String barcode;            // OFF: code / USDA: fdcId as string
  final String name;               // OFF: product_name
  final String? brand;             // OFF: brands
  final String? displayQuantity;   // OFF: quantity — e.g. "400 g", "330 ml"
  final double? totalGrams;        // OFF: product_quantity (numeric)
  final String? servingLabel;      // OFF: serving_size — e.g. "1 can (330 ml)"
  final double? servingGrams;      // OFF: serving_quantity (numeric, grams)
  final String? imageUrl;          // OFF: image_url (400px)
  final String? imageThumbnailUrl; // OFF: image_front_small_url (200px)
  final String? ingredientsText;   // OFF: ingredients_text
  final List<String> allergenTags; // OFF: allergens_tags — e.g. ["en:nuts"]
  final List<String> tracesTags;   // OFF: traces_tags — e.g. ["en:milk"]
  final List<String> labelTags;    // OFF: labels_tags — e.g. ["en:no-gluten"]
  final String? nutriscoreGrade;   // OFF: nutriscore_grade — "a"–"e"
  final String? ecoscoreGrade;     // OFF: ecoscore_grade — "a"–"e"
  final int? novaGroup;            // OFF: nova_group — 1–4 (null if unknown)
  final NutrientLevels? nutrientLevels; // OFF: nutrient_levels
  final Nutriments nutriments;
  final String source;             // "openfoodfacts" | "usda" | "manual"
}
```

### Fields reference (OpenFoodFacts → model)

| OFF field | Model field | Notes |
|---|---|---|
| `code` | `barcode` | |
| `product_name` | `name` | Fallback: `generic_name` |
| `brands` | `brand` | May be empty |
| `quantity` | `displayQuantity` | Display only — e.g. `"400.0 g"` |
| `product_quantity` | `totalGrams` | Numeric. May be 0 (bad data) — treat 0 as null |
| `product_quantity_unit` | — | Ignored — always work in grams |
| `serving_size` | `servingLabel` | Human string — e.g. `"1 jar (400 g)"` |
| `serving_quantity` | `servingGrams` | Float, in grams — use for per-serving calc |
| `image_url` | `imageUrl` | 400px — product detail screen |
| `image_front_small_url` | `imageThumbnailUrl` | 200px — list items |
| `ingredients_text` | `ingredientsText` | May be in wrong language |
| `allergens_tags` | `allergenTags` | e.g. `["en:nuts", "en:milk"]` |
| `traces_tags` | `tracesTags` | e.g. `["en:soybeans"]` |
| `labels_tags` | `labelTags` | e.g. `["en:no-gluten", "en:organic"]` |
| `nutriscore_grade` | `nutriscoreGrade` | `"a"`–`"e"` or `"unknown"` → null |
| `ecoscore_grade` | `ecoscoreGrade` | `"a"`–`"e"`, `"not-applicable"` → null |
| `nova_group` | `novaGroup` | 1–4. Missing when ingredients unknown → null |
| `nutrient_levels` | `nutrientLevels` | See NutrientLevels below |
| `nutriments` | `nutriments` | See Nutriments below |
| `nutrition_data_per` | — | Used during parsing only — not stored |

> **serving_size / serving_quantity:** always keep both. `servingGrams` drives all per-serving calculations. `servingLabel` is display-only. Both are frequently missing — always nullable.

---

## Nutriments

All values **per 100g** (or 100ml for liquids). All fields nullable — data quality varies per product.

```dart
class Nutriments {
  final double? caloriesPer100g;     // energy-kcal_100g  (kcal)
  final double? carbsPer100g;        // carbohydrates_100g (g)
  final double? sugarsPer100g;       // sugars_100g        (g)
  final double? fatPer100g;          // fat_100g           (g)
  final double? saturatedFatPer100g; // saturated-fat_100g (g)
  final double? proteinPer100g;      // proteins_100g      (g)
  final double? saltPer100g;         // salt_100g          (g)
  final double? fiberPer100g;        // fiber_100g         (g) — often missing

  // Per-serving helpers
  double calories({required double grams}) => (caloriesPer100g     ?? 0) / 100 * grams;
  double carbs({required double grams})    => (carbsPer100g        ?? 0) / 100 * grams;
  double fat({required double grams})      => (fatPer100g          ?? 0) / 100 * grams;
  double protein({required double grams})  => (proteinPer100g      ?? 0) / 100 * grams;
  double sugars({required double grams})   => (sugarsPer100g       ?? 0) / 100 * grams;
  double salt({required double grams})     => (saltPer100g         ?? 0) / 100 * grams;
}
```

> **Nutella example (per 100g):** calories=539 kcal, carbs=57.5g, sugars=56.3g, fat=30.9g, saturatedFat=10.6g, protein=6.3g, salt=0.11g, fiber=null

---

## NutrientLevels

Traffic-light qualitative assessment. Present on most products — null if OFF didn't compute it.

```dart
class NutrientLevels {
  final NutrientLevel? fat;          // nutrient_levels.fat
  final NutrientLevel? saturatedFat; // nutrient_levels.saturated-fat
  final NutrientLevel? sugars;       // nutrient_levels.sugars
  final NutrientLevel? salt;         // nutrient_levels.salt
}

enum NutrientLevel { low, moderate, high }
```

> **Nutella example:** fat=high, saturatedFat=high, sugars=high, salt=low

---

## AppUser

Stored in Firestore at `users/{uid}`.

```dart
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final NutritionGoals goals;
  final NotificationSettings notifications;
}
```

---

## NutritionGoals

Embedded in `AppUser`. User's daily targets — set during onboarding, editable in profile.

```dart
class NutritionGoals {
  final double calories; // kcal/day
  final double protein;  // g/day
  final double carbs;    // g/day
  final double fat;      // g/day
  final double water;    // ml/day
}
```

> Default values computed from onboarding inputs (age, weight, height, activity level, goal).

---

## NotificationSettings

Embedded in `AppUser`.

```dart
class NotificationSettings {
  final bool enabled;
  final int reminderHour;   // 0–23
  final int reminderMinute; // 0–59
  final bool goalReachedAlert;
}
```

---

## MealEntry

One food item logged within a meal.
Stored inside `users/{uid}/nutrition_logs/{date}` as an array element.

```dart
class MealEntry {
  final String id;               // UUID
  final String productBarcode;
  final String productName;
  final String? productImageUrl;
  final MealType mealType;
  final double servingGrams;     // amount consumed (g)
  final Nutriments nutriments;   // values for this serving (not per 100g)
  final DateTime loggedAt;
}

enum MealType { breakfast, lunch, dinner, snack }
```

> `nutriments` stores **pre-computed values for the actual serving** (not per-100g). Avoids re-computing at query time.
> Compute on write: `entry.nutriments.calories = product.nutriments.caloriesPer100g / 100 * servingGrams`

---

## NutritionLog

Daily log — one document per day per user.
Stored in Firestore at `users/{uid}/nutrition_logs/{date}` where `date` = `"2025-05-01"`.

```dart
class NutritionLog {
  final String date;              // "2025-05-01"
  final List<MealEntry> entries;
  final double waterMl;           // total water logged for the day

  // Computed getters (sum over entries)
  double get totalCalories => entries.fold(0, (s, e) => s + (e.nutriments.caloriesPer100g ?? 0));
  double get totalProtein  => entries.fold(0, (s, e) => s + (e.nutriments.proteinPer100g  ?? 0));
  double get totalCarbs    => entries.fold(0, (s, e) => s + (e.nutriments.carbsPer100g    ?? 0));
  double get totalFat      => entries.fold(0, (s, e) => s + (e.nutriments.fatPer100g      ?? 0));
}
```

---

## SavedProduct

Product the user explicitly saved to their library.
Stored in Firestore at `users/{uid}/saved_products/{barcode}`.

```dart
class SavedProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final Nutriments nutriments;
  final String source;      // "openfoodfacts" | "usda" | "manual"
  final DateTime savedAt;
}
```

---

## ShoppingPrice

A price observation for a product at a specific store.
Stored in Firestore at `users/{uid}/shopping_prices/{priceId}`.

```dart
class ShoppingPrice {
  final String id;               // UUID
  final String barcode;
  final String productName;
  final String? productImageUrl;
  final String storeName;        // e.g. "Continente", "Pingo Doce"
  final double price;            // total price paid (€)
  final double quantity;         // package amount — e.g. 400
  final String unit;             // "g" | "ml" | "kg" | "L"
  final double pricePerKg;       // pre-computed: (price / quantity) * 1000
  final DateTime observedAt;
}
```

> `pricePerKg` (or per litre) is computed on save — it's the comparison value across stores and sizes.

---

## Model Relationships

```
AppUser
├── NutritionGoals          (embedded in user doc)
├── NotificationSettings    (embedded in user doc)
├── nutrition_logs/
│   └── {date}/             one doc per day — e.g. "2025-05-01"
│       ├── entries[]       MealEntry array (embedded)
│       └── waterMl         float (embedded)
├── saved_products/
│   └── {barcode}           SavedProduct
└── shopping_prices/
    └── {priceId}           ShoppingPrice
```

---

## Recommended `fields` param (OpenFoodFacts API)

Use this to avoid fetching the full product object (~1800 lines for Nutella):

```
product_name,brands,quantity,product_quantity,product_quantity_unit,
serving_size,serving_quantity,image_url,image_front_small_url,
ingredients_text,allergens_tags,traces_tags,labels_tags,
nutriments,nutrient_levels,nutriscore_grade,ecoscore_grade,
nova_group,nutrition_data_per
```
