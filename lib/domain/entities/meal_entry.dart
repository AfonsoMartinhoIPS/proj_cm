enum MealType {
  breakfast(label: 'Pequeno-almoço'),
  lunch(label: 'Almoço'),
  dinner(label: 'Jantar'),
  snack(label: 'Snack');

  final String label;
  const MealType({required this.label});
}

/// A single logged meal item inside a daily [NutritionLog].
///
/// Nutrient totals are stored **already scaled to the consumed serving** -
/// i.e. `calories` is the total kcal for `servingGrams` grams of this product,
/// not the per-100g rate. This means reading the doc never requires the
/// caller to do any math: just display the value.
///
/// The scaling is performed once at log time (in `AddMealScreen._submit`)
/// from the product's per-100g [Nutriments]. Stored values are frozen - they
/// won't change if the global product is updated later.
class MealEntry {
  final String id;
  final String productBarcode;
  final String productName;
  final String? productImageUrl;
  final MealType mealType;

  /// Grams of the product consumed in this entry.
  final double servingGrams;

  // Scaled-for-serving nutrient totals. All values are in their natural units
  // (kcal for calories, grams for macros).
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.productBarcode,
    required this.productName,
    this.productImageUrl,
    required this.mealType,
    required this.servingGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  // Convenience aliases so existing call sites (`entry.totalCalories`) keep
  // working. They just return the stored value - no math.
  double get totalCalories => calories;
  double get totalProtein => protein;
  double get totalCarbs => carbs;
  double get totalFat => fat;
}
