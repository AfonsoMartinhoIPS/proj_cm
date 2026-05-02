import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/entities/meal_entry.dart';

class NutritionLog {
  final String date; // "2025-05-01"
  final List<MealEntry> entries;
  final double waterMl;
  final NutritionGoals goals; // snapshot of goals on this day

  const NutritionLog({
    required this.date,
    required this.entries,
    required this.waterMl,
    required this.goals,
  });

  double get totalCalories => entries.fold(0, (s, e) => s + e.nutriments.calories(grams: e.servingGrams));
  double get totalProtein  => entries.fold(0, (s, e) => s + e.nutriments.protein(grams: e.servingGrams));
  double get totalCarbs    => entries.fold(0, (s, e) => s + e.nutriments.carbs(grams: e.servingGrams));
  double get totalFat      => entries.fold(0, (s, e) => s + e.nutriments.fat(grams: e.servingGrams));
}
