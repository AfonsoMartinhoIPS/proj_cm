import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';

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

  // Per-entry totals are already scaled to the consumed serving, so summing
  // the stored values gives the day's total.
  double get totalCalories => entries.fold(0, (s, e) => s + e.calories);
  double get totalProtein  => entries.fold(0, (s, e) => s + e.protein);
  double get totalCarbs    => entries.fold(0, (s, e) => s + e.carbs);
  double get totalFat      => entries.fold(0, (s, e) => s + e.fat);
}
