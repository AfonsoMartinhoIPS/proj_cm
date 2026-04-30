# API Reference

## OpenFoodFacts

**Base URL:** `https://world.openfoodfacts.org`  
**Auth:** None required  
**Format:** JSON  
**Rate limit:** No official limit — add `User-Agent` header with app name (recommended by OpenFoodFacts)

---

## Additional Endpoints — OpenFoodFacts Search

Search products by name (no barcode needed):

```
GET https://world.openfoodfacts.org/cgi/search.pl
  ?search_terms={query}
  &json=1
  &page_size=20
  &fields=code,product_name,brands,image_url,nutriments
```

**Example:**
```
GET https://world.openfoodfacts.org/cgi/search.pl?search_terms=coca+cola&json=1&page_size=10&fields=code,product_name,brands,nutriments
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
      "nutriments": { ... }
    }
  ]
}
```

> Covers packaged/branded products only. For generic whole foods (apple, rice, chicken) use USDA below.

---

## USDA FoodData Central

**Purpose:** Nutrition data for generic/whole foods and ingredients — no barcode needed  
**Base URL:** `https://api.nal.usda.gov/fdc/v1`  
**Auth:** Free API key — register at [https://fdc.nal.usda.gov/api-guide.html](https://fdc.nal.usda.gov/api-guide.html)  
**Rate limit:** 3,600 requests/hour (free tier)

### Search foods by name

```
GET /foods/search?query={term}&api_key={key}&dataType=Foundation,SR%20Legacy&pageSize=10
```

**Example:**
```
GET https://api.nal.usda.gov/fdc/v1/foods/search?query=chicken+breast&api_key=DEMO_KEY&pageSize=5
```

**Response shape:**
```json
{
  "totalHits": 38,
  "foods": [
    {
      "fdcId": 171477,
      "description": "Chicken, broilers or fryers, breast, meat only, cooked, roasted",
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

### Get food by ID

```
GET /food/{fdcId}?api_key={key}
```

### Key Nutrient IDs

| Nutrient | ID |
|---|---|
| Energy (kcal) | 1008 |
| Protein | 1003 |
| Carbohydrates | 1005 |
| Total fat | 1004 |
| Fiber | 1079 |
| Sugars | 2000 |
| Saturated fat | 1258 |
| Sodium | 1093 |

> Values are per 100g. Same calculation as OpenFoodFacts.

### Data Types

| Type | Content |
|---|---|
| `Foundation` | Unprocessed/minimally processed whole foods — most reliable |
| `SR Legacy` | USDA standard reference — broad coverage |
| `Branded` | Packaged branded products (overlaps with OpenFoodFacts) |

Recommend filtering to `Foundation,SR Legacy` for generic ingredient searches.

---

## API Strategy for the App

| User action | API to call |
|---|---|
| Scan barcode | OpenFoodFacts `/api/v2/product/{barcode}` |
| Search by product name (packaged) | OpenFoodFacts `/cgi/search.pl` |
| Search generic food / ingredient | USDA FoodData Central `/foods/search` |
| Manual entry (no scan, no search match) | User inputs nutrition manually |

Store `source: "openfoodfacts" | "usda" | "manual"` on each saved product in Firestore.

---

## Endpoints

### Get product by barcode

```
GET /api/v2/product/{barcode}.json
```

**Example:**
```
GET https://world.openfoodfacts.org/api/v2/product/5449000000996.json
```

**Query params (optional):**
| Param | Value | Purpose |
|---|---|---|
| `fields` | comma-separated field names | Limit response size |

**Recommended fields param:**
```
fields=product_name,brands,quantity,image_url,ingredients_text,nutriments,nutriments_estimated
```

---

## Response Structure

### Success (`status: 1`)
```json
{
  "status": 1,
  "product": {
    "product_name": "Coca-Cola",
    "brands": "Coca-Cola",
    "quantity": "330 ml",
    "image_url": "https://...",
    "ingredients_text": "Carbonated water, sugar...",
    "nutriments": {
      "energy-kcal_100g": 42,
      "proteins_100g": 0,
      "carbohydrates_100g": 10.6,
      "sugars_100g": 10.6,
      "fat_100g": 0,
      "saturated-fat_100g": 0,
      "fiber_100g": 0,
      "salt_100g": 0
    }
  }
}
```

### Not found (`status: 0`)
```json
{
  "status": 0,
  "status_verbose": "product not found"
}
```

---

## Fields Used in App

| Field | Path | Notes |
|---|---|---|
| Name | `product.product_name` | May be empty — fallback to `product.generic_name` |
| Brand | `product.brands` | May be empty |
| Quantity | `product.quantity` | e.g. "330 ml", "500 g" |
| Image | `product.image_url` | May be null |
| Ingredients | `product.ingredients_text` | May be empty or in another language |
| Calories | `product.nutriments.energy-kcal_100g` | Per 100g/ml |
| Protein | `product.nutriments.proteins_100g` | Per 100g/ml |
| Carbs | `product.nutriments.carbohydrates_100g` | Per 100g/ml |
| Sugar | `product.nutriments.sugars_100g` | Per 100g/ml |
| Fat | `product.nutriments.fat_100g` | Per 100g/ml |
| Saturated fat | `product.nutriments.saturated-fat_100g` | Per 100g/ml |
| Fiber | `product.nutriments.fiber_100g` | Per 100g/ml |
| Salt | `product.nutriments.salt_100g` | Per 100g/ml |

> All nutriment values are per 100g or 100ml. To calculate for a given serving size:
> `value = (field_100g / 100) * serving_grams`

---

## Error Cases to Handle

| Case | Detection | Handling |
|---|---|---|
| Product not found | `status == 0` | Show "product not found" UI |
| Missing name | `product_name` is null/empty | Show "Unknown product" |
| Missing nutriments | `nutriments` is null or field missing | Show "—" or 0 |
| Network error | HTTP exception / timeout | Show error + retry button |
| Invalid barcode | `status == 0` or HTTP 404 | Show "product not found" UI |

---

## Dart Model (Domain Layer)

```dart
class Product {
  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;
  final String? ingredientsText;
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
}
```

---

## Dio Setup (Data Layer)

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://world.openfoodfacts.org',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
  headers: {
    'User-Agent': 'NutritionApp - Flutter - github.com/yourrepo',
  },
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
        unit: string         // "g" | "ml" | "kg" | "L"
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