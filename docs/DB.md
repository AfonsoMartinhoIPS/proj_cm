# Database Design — NutriScan

Firestore (NoSQL document database). No tables, no joins.
Data is organized as: **Collection → Document → Fields**.

All user data lives under `users/{uid}` — each user only reads and writes their own data.
Product data lives in a global `products` collection shared across all users.

---

## Overview

```
products/
  {barcode}                  ← global product cache (shared)

users/
  {uid}                      ← user profile + goals + settings
    saved_products/
      {barcode}              ← product saved by this user + notes
    nutrition_logs/
      {date}                 ← everything eaten on a given day
```

---

## Collection: `products`

**What it is:** A global cache of food products fetched from OpenFoodFacts or USDA. Shared across all users — if one user scans Nutella, every other user gets it from Firestore instantly without hitting the API again.

**Document ID:** the product barcode (e.g. `3017624010701`) or USDA fdcId as string.

**When written:** first time any user scans or searches a product that isn't already in Firestore.

**When read:** every time a product detail screen opens, or when building a saved products list.

```
products/{barcode}
  name: string                  // "Nutella"
  brand: string | null          // "Ferrero"
  displayQuantity: string | null// "400 g"
  imageUrl: string | null       // 400px front image
  imageThumbnailUrl: string | null // 200px for lists
  ingredientsText: string | null
  allergenTags: string[]        // ["en:nuts", "en:milk"]
  tracesTags: string[]          // ["en:soybeans"]
  labelTags: string[]           // ["en:no-gluten"]
  nutriscoreGrade: string | null// "a" – "e"
  novaGroup: number | null      // 1 – 4
  source: string                // "openfoodfacts" | "usda" | "manual"
  fetchedAt: timestamp          // when last fetched from API

  nutriments: {
    caloriesPer100g: number | null
    carbsPer100g: number | null
    sugarsPer100g: number | null
    fatPer100g: number | null
    saturatedFatPer100g: number | null
    proteinPer100g: number | null
    saltPer100g: number | null
    fiberPer100g: number | null
  }

  nutrientLevels: {             // traffic light — null if unavailable
    fat: "low" | "moderate" | "high" | null
    saturatedFat: "low" | "moderate" | "high" | null
    sugars: "low" | "moderate" | "high" | null
    salt: "low" | "moderate" | "high" | null
  }
```

> **Re-fetch strategy:** if `fetchedAt` is older than 30 days, re-fetch from API and update the document. Product data rarely changes but can be corrected by the OFF community.

---

## Collection: `users`

**What it is:** One document per registered user. Created on registration. Contains everything personal to the user — profile, computed goals, notification preferences, and the raw physical data used to compute those goals.

**Document ID:** Firebase Auth UID.

```
users/{uid}
  displayName: string           // "Samuel Silva"
  email: string                 // "samuel@email.com"
  createdAt: timestamp

  profile: {
    age: number                 // years
    weightKg: number            // kg
    heightCm: number            // cm
    sex: "male" | "female"
    activityLevel: number       // 1.2 (sedentary) → 1.9 (very active)
    goalType: "lose" | "maintain" | "gain"
  }

  goals: {
    calories: number            // kcal/day
    protein: number             // g/day
    carbs: number               // g/day
    fat: number                 // g/day
    water: number               // ml/day
  }

  notifications: {
    enabled: boolean
    reminderHour: number        // 0 – 23
    reminderMinute: number      // 0 – 59
    goalReachedAlert: boolean
  }
```

> `profile` stores the raw onboarding inputs. `goals` stores the computed daily targets. Both are needed — `profile` for displaying in the profile screen and recalculating goals if the user updates their weight or activity level.

---

## Subcollection: `users/{uid}/saved_products`

**What it is:** Products the user has explicitly saved to their personal library — either by scanning, searching, or adding from product detail. Gives the user quick access without rescanning.

**Document ID:** product barcode (same as in `products/{barcode}`).

**Key design decision:** Does not duplicate all product data. Stores only a **small snapshot** of key fields for rendering the list (name, image, calories) — the full product is fetched from `products/{barcode}` when opening detail.

```
users/{uid}/saved_products/{barcode}
  savedAt: timestamp

  // snapshot — for rendering the list without a second read per item
  name: string
  brand: string | null
  imageUrl: string | null
  caloriesPer100g: number | null

  // user-specific
  notes: [
    {
      id: string                // UUID
      text: string              // free text — e.g. "Continente 2.49€", "Good post-workout"
      createdAt: timestamp
    }
  ]
```

> Notes are a simple time-stamped feed embedded in the document. The user can log anything — price observations, personal comments, reminders. Free text, no structured fields.

---

## Subcollection: `users/{uid}/nutrition_logs`

**What it is:** The user's daily food diary. One document per day. Contains every meal entry for that day, the water intake, pre-computed daily totals, and a snapshot of the user's goals on that day.

**Document ID:** date string in `YYYY-MM-DD` format (e.g. `2025-05-01`).

**When written:** created on the first meal entry of the day. Updated on every add, edit, or delete of an entry, and on every water log.

**When read:**
- Meals tab → today's document (full read including entries)
- History week/month → multiple documents, only totals fields needed

```
users/{uid}/nutrition_logs/{date}
  date: string                  // "2025-05-01" — matches document ID

  // pre-computed totals — updated on every entry change
  totalCalories: number         // kcal
  totalProtein: number          // g
  totalCarbs: number            // g
  totalFat: number              // g
  waterMl: number               // ml

  // snapshot of goals active on this day
  goals: {
    calories: number
    protein: number
    carbs: number
    fat: number
    water: number
  }

  // all meal entries for the day
  entries: [
    {
      id: string                // UUID
      mealType: "breakfast" | "lunch" | "dinner" | "snack"
      productBarcode: string
      productName: string       // snapshot — avoids extra read to products collection
      productImageUrl: string | null
      servingGrams: number      // actual amount consumed
      loggedAt: timestamp

      // pre-computed for this serving: (nutrientPer100g / 100) * servingGrams
      nutriments: {
        calories: number
        protein: number
        carbs: number
        fat: number
      }
    }
  ]
```

> **Why pre-computed totals?** History views need one number per day. Without stored totals, getting a week = 7 reads + summing all entries in code. With totals stored, 7 reads give 7 ready numbers — no extra work.

> **Why goals snapshot?** If the user updates their goals today, last month's history should still compare against last month's goals. Without the snapshot, history becomes misleading.

> **Why nutriments snapshot per entry?** The serving was consumed at a specific moment — its nutritional value is fixed. Avoids re-fetching the product and recalculating on every read.

---

## Read Patterns

| Screen | What is read | Reads |
|---|---|---|
| Home screen | `users/{uid}` + `nutrition_logs/{today}` | 2 |
| Meals tab | `nutrition_logs/{today}` | 1 |
| Add meal → product list | `saved_products/` (collection) | 1 |
| Product detail | `products/{barcode}` | 1 |
| History — day view | `nutrition_logs/{date}` | 1 |
| History — week view | `nutrition_logs/` (7 docs, totals only) | 7 |
| History — month view | `nutrition_logs/` (up to 31 docs, totals only) | ≤ 31 |
| Saved products list | `saved_products/` (collection) | 1 |
| Profile screen | `users/{uid}` | 1 |

---

## Security Rules (summary)

```
products/{barcode}
  read:  any authenticated user
  write: any authenticated user   // first scan creates the doc

users/{uid}/**
  read:  only if request.auth.uid == uid
  write: only if request.auth.uid == uid
```

No user can read or write another user's data.
