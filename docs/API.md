# API Reference

---

## OpenFoodFacts

**Auth:** None required  
**Format:** JSON  

### Environments

| Environment | Base URL | When to use |
|---|---|---|
| Production | `https://world.openfoodfacts.org` | Release builds only |
| Staging | `https://world.openfoodfacts.net` | Development & testing |

> Always use **staging** during development. Production has the real product database — staging keeps it safe.

**Rate limits:**
- Product lookup: **15 requests/min/IP**
- Search: **10 requests/min/IP**
- HTTP `503` returned when exceeded

**Required header** (recommended by OpenFoodFacts):
```
User-Agent: NutriScan - Flutter - contact@email.com
```

---

### Endpoint: Get product by barcode

```
GET /api/v2/product/{barcode}.json?fields={fields}
```

**Recommended fields:**
```
product_name,brands,quantity,serving_size,serving_quantity,image_url,
ingredients_text,nutriments,nutriment_levels,nova_group,nutriscore_grade
```

**Example (staging):**
```
GET https://world.openfoodfacts.net/api/v2/product/5449000000996.json?fields=product_name,brands,quantity,serving_size,serving_quantity,image_url,ingredients_text,nutriments,nova_group,nutriscore_grade
```

#### Response — Found (`status: 1`)

```json
{
  "code": "5449000000996",
  "status": 1,
  "status_verbose": "product found",
  "product": {
    "product_name": "Coke Original Taste",
    "brands": "Coca-Cola",
    "quantity": "330 ml",
    "serving_size": "1 can (330 ml)",
    "serving_quantity": 330,
    "image_url": "https://images.openfoodfacts.net/...",
    "ingredients_text": "Carbonated Water, Sugar, ...",
    "nova_group": 4,
    "nutriscore_grade": "e",
    "nutriments": {
      "energy_100g": 175,
      "energy-kcal_100g": 42,
      "carbohydrates_100g": 10.6,
      "sugars_100g": 10.6,
      "fat_100g": 0,
      "saturated-fat_100g": 0,
      "proteins_100g": 0,
      "salt_100g": 0,
      "fiber_100g": 0,
      "sodium_100g": 0
    }
  }
}
```

#### Response — Not found (`status: 0`)

```json
{
  "status": 0,
  "status_verbose": "product not found"
}
```

> HTTP is always `200`. Check the inner `status` field — `1` = found, `0` = not found.

---

### Nutriments Object — Key Naming Convention

Every nutrient comes in 5 variants:

| Suffix | Meaning |
|---|---|
| `<name>` (bare) | Value as entered by contributor |
| `<name>_value` | Same as bare |
| `<name>_100g` | Normalized to per 100g ← **use this** |
| `<name>_serving` | Per serving (scaled by `serving_quantity`) |
| `<name>_unit` | Unit string |

**Always use `_100g` fields.** Then calculate per serving:
```
value = (field_100g / 100) * serving_grams
```

Energy is split into two separate keys:
- `energy_100g` → kJ
- `energy-kcal_100g` → kcal ← **use this for calories**

#### Nutrient keys and units

| Nutrient | Key | Unit |
|---|---|---|
| Calories | `energy-kcal_100g` | kcal |
| Energy (kJ) | `energy_100g` | kJ |
| Carbohydrates | `carbohydrates_100g` | g |
| Sugar | `sugars_100g` | g |
| Fat | `fat_100g` | g |
| Saturated fat | `saturated-fat_100g` | g |
| Protein | `proteins_100g` | g |
| Salt | `salt_100g` | g |
| Sodium | `sodium_100g` | g |
| Fiber | `fiber_100g` | g |

> Hyphenated names (`energy-kcal`, `saturated-fat`) use `-` as separator, **not** `_`.

#### `nutriment_levels` (when present)

Qualitative traffic-light values for selected nutrients:

```json
"nutriment_levels": {
  "fat": "low",
  "saturated-fat": "low",
  "sugars": "high",
  "salt": "low"
}
```

Possible values: `"low"`, `"moderate"`, `"high"`.

---

### Extra product fields

| Field | Type | Values / Notes |
|---|---|---|
| `nova_group` | int | 1–4 (1 = unprocessed, 4 = ultra-processed) |
| `nutriscore_grade` | string | `"a"`–`"e"` or `"unknown"` |
| `ecoscore_grade` | string | `"a"`–`"e"`, `"not-applicable"`, `"unknown"` |
| `serving_quantity` | number | grams (float) — use for per-serving calc |
| `serving_size` | string | Human-readable label e.g. `"1 can (330 ml)"` |
| `nutrition_data_per` | string | `"100g"` or `"serving"` (base the contributor used) |

---

### Endpoint: Search by name

```
GET /cgi/search.pl?search_terms={query}&json=1&page_size=20&fields={fields}
```

**Example (staging):**
```
GET https://world.openfoodfacts.net/cgi/search.pl?search_terms=coca+cola&json=1&page_size=10&fields=code,product_name,brands,image_url,nutriments,nutriscore_grade
```

**Response:**
```json
{
  "count": 142,
  "products": [
    {
      "code": "5449000000996",
      "product_name": "Coca-Cola",
      "brands": "Coca-Cola",
      "nutriscore_grade": "e",
      "nutriments": { "energy-kcal_100g": 42, "..." : "..." }
    }
  ]
}
```

> Covers packaged/branded products only. For generic whole foods (apple, rice, chicken) use USDA below.

---

## USDA FoodData Central

**Purpose:** Nutrition data for generic/whole foods — no barcode needed  
**Base URL:** `https://api.nal.usda.gov/fdc/v1`  
**Auth:** Free API key — register at https://fdc.nal.usda.gov/api-guide.html  
**Rate limit:** 3,600 requests/hour (free tier)

### Endpoint: Search foods by name

```
GET /foods/search?query={term}&api_key={key}&dataType=Foundation,SR%20Legacy&pageSize=10
```

**Response shape:**
```json
{
  "totalHits": 38,
  "foods": [
    {
      "fdcId": 171477,
      "description": "Chicken, breast, meat only, cooked, roasted",
      "dataType": "SR Legacy",
      "foodNutrients": [
        { "nutrientId": 1008, "nutrientName": "Energy", "unitName": "KCAL", "value": 165 },
        { "nutrientId": 1003, "nutrientName": "Protein", "unitName": "G", "value": 31 },
        { "nutrientId": 1005, "nutrientName": "Carbohydrate, by difference", "unitName": "G", "value": 0 },
        { "nutrientId": 1004, "nutrientName": "Total lipid (fat)", "unitName": "G", "value": 3.6 }
      ]
    }
  ]
}
```

> Values are per 100g. Same `(value / 100) * serving_grams` formula applies.

**Search results include nutrients inline** — no second request needed for basic macros (calories, protein, carbs, fat). Only call `/food/{fdcId}` when opening product detail and needing extended nutrients (fiber, saturated fat, sodium).

**Result picking strategy:**
- Show list to user — never auto-pick
- Prefer `Foundation` > `SR Legacy` results (sort client-side by dataType)
- User selects the most relevant match

### USDA Product ID Strategy

USDA products have no barcode. To store them in Firestore alongside OFF products (which use barcodes as document IDs), prefix the `fdcId` with `usda_`:

```
Barcode format:  5449000000996          (OFF — real barcode)
USDA format:     usda_171477            (USDA — prefixed fdcId)
```

This prefix is used as the document ID in both `products/{id}` and `saved_products/{id}`. The `source` field (`"usda"`) is the canonical indicator of origin — the prefix just ensures ID uniqueness across sources.

```dart
String usdaProductId(int fdcId) => 'usda_$fdcId';
```

### Endpoint: Get food by ID

```
GET /food/{fdcId}?api_key={key}
```

### Key Nutrient IDs

| Nutrient | ID | Unit |
|---|---|---|
| Energy (kcal) | 1008 | kcal |
| Protein | 1003 | g |
| Carbohydrates | 1005 | g |
| Total fat | 1004 | g |
| Fiber | 1079 | g |
| Sugars | 2000 | g |
| Saturated fat | 1258 | g |
| Sodium | 1093 | mg |

### Data Types

| Type | Content |
|---|---|
| `Foundation` | Unprocessed/minimally processed whole foods — most reliable |
| `SR Legacy` | USDA standard reference — broad coverage |
| `Branded` | Packaged branded products (overlaps with OpenFoodFacts) |

Filter to `Foundation,SR Legacy` for generic ingredient searches.

---

## API Strategy for the App

| User action | API |
|---|---|
| Scan barcode | OpenFoodFacts `/api/v2/product/{barcode}` |
| Search by product name (packaged) | OpenFoodFacts `/cgi/search.pl` |
| Search generic food / ingredient | USDA `/foods/search` |
| Manual entry (no match) | User inputs manually |

Store `source: "openfoodfacts" | "usda" | "manual"` on each saved product in Firestore.

**Product ID conventions:**

| Source | Document ID | Example |
|---|---|---|
| OpenFoodFacts | barcode (string) | `5449000000996` |
| USDA | `usda_` + fdcId | `usda_171477` |
| Manual | UUID | `a1b2c3d4-...` |

---

## Fields Used in App

| Field | OFF path | Notes |
|---|---|---|
| Name | `product.product_name` | Fallback to `product.generic_name` |
| Brand | `product.brands` | May be empty |
| Quantity | `product.quantity` | e.g. `"330 ml"`, `"500 g"` |
| Serving size label | `product.serving_size` | Human label e.g. `"1 can (330 ml)"` |
| Serving grams | `product.serving_quantity` | Float, grams |
| Image | `product.image_url` | May be null |
| Ingredients | `product.ingredients_text` | May be empty or wrong language |
| Calories | `product.nutriments.energy-kcal_100g` | kcal per 100g |
| Protein | `product.nutriments.proteins_100g` | g per 100g |
| Carbs | `product.nutriments.carbohydrates_100g` | g per 100g |
| Sugar | `product.nutriments.sugars_100g` | g per 100g |
| Fat | `product.nutriments.fat_100g` | g per 100g |
| Saturated fat | `product.nutriments.saturated-fat_100g` | g per 100g |
| Fiber | `product.nutriments.fiber_100g` | g per 100g |
| Salt | `product.nutriments.salt_100g` | g per 100g |
| Nutriscore | `product.nutriscore_grade` | `"a"`–`"e"` |
| NOVA group | `product.nova_group` | 1–4 |

---

## Error Cases to Handle

| Case | Detection | Handling |
|---|---|---|
| Product not found | `status == 0` | Show "product not found" UI |
| Rate limited | HTTP `503` | Retry after delay |
| Missing name | `product_name` null/empty | Fallback to `"Unknown product"` |
| Missing nutriments | field null or missing | Show `"—"` or `0` |
| Network error | HTTP exception / timeout | Show error + retry button |

---

## Dart Model (Domain Layer)

```dart
class Product {
  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? servingSize;      // e.g. "1 can (330 ml)"
  final double? servingGrams;     // e.g. 330.0
  final String? imageUrl;
  final String? ingredientsText;
  final String? nutriscoreGrade;  // "a"–"e"
  final int? novaGroup;           // 1–4
  final String source;            // "openfoodfacts" | "usda" | "manual"
  final Nutriments nutriments;
}

class Nutriments {
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? sugarPer100g;
  final double? fatPer100g;
  final double? saturatedFatPer100g;
  final double? fiberPer100g;
  final double? saltPer100g;

  double calories({required double grams}) => (caloriesPer100g ?? 0) / 100 * grams;
  double protein({required double grams}) => (proteinPer100g ?? 0) / 100 * grams;
  double carbs({required double grams}) => (carbsPer100g ?? 0) / 100 * grams;
  double fat({required double grams}) => (fatPer100g ?? 0) / 100 * grams;
}
```

---

## Dio Setup (Data Layer)

```dart
// Production
final offProdDio = Dio(BaseOptions(
  baseUrl: 'https://world.openfoodfacts.org',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
  headers: {'User-Agent': 'NutriScan - Flutter - contact@email.com'},
));

// Staging (use during development)
final offStagingDio = Dio(BaseOptions(
  baseUrl: 'https://world.openfoodfacts.net',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
  headers: {'User-Agent': 'NutriScan - Flutter - contact@email.com'},
));
```

---

## Firebase (Auth + Firestore)

**Auth:** Firebase Authentication — Email/Password  
**No external endpoints** — handled via FlutterFire SDK

### Firestore Collections

```
users/
  {uid}/
    displayName: string
    email: string
    createdAt: timestamp

nutrition_logs/
  {uid}/
    entries/
      {entryId}/
        barcode: string
        productName: string
        servingGrams: number
        loggedAt: timestamp
        nutriments: { calories, protein, carbs, fat }

saved_products/
  {uid}/
    products/
      {barcode}/
        name: string
        brand: string
        imageUrl: string
        nutriments: { ... }
        savedAt: timestamp

shopping_items/
  {uid}/
    items/
      {itemId}/
        barcode: string
        productName: string
        storeName: string
        price: number
        quantity: number
        unit: string           // "g" | "ml" | "kg" | "L"
        pricePerKgOrL: number  // computed on save
        addedAt: timestamp
```

---

## Notifications

**Package:** `flutter_local_notifications`  
**No external API** — scheduled locally on device

| Notification | Trigger | Content |
|---|---|---|
| Daily log reminder | Fixed time (e.g. 20:00) | "Don't forget to log today's meals" |
| Goal reached | When daily calorie goal hit | "You've hit your calorie goal today" |
