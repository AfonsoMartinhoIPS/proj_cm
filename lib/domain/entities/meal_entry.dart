import 'package:nutri_scan/domain/entities/nutriments.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final String id;
  final String productBarcode;
  final String productName;
  final String? productImageUrl;
  final MealType mealType;
  final double servingGrams;
  final Nutriments nutriments; // pre-computed for this serving
  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.productBarcode,
    required this.productName,
    this.productImageUrl,
    required this.mealType,
    required this.servingGrams,
    required this.nutriments,
    required this.loggedAt,
  });

  /// Total calories for the consumed serving. Falls back to 0 when the
  /// product has no caloriesPer100g, so callers never crash on nulls.
  double get totalCalories => nutriments.calories(grams: servingGrams);

  /// Macros for the consumed serving — mirror totalCalories.
  double get totalProtein => nutriments.protein(grams: servingGrams);
  double get totalCarbs   => nutriments.carbs(grams: servingGrams);
  double get totalFat     => nutriments.fat(grams: servingGrams);
}
