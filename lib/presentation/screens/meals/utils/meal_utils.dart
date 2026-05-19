

import 'package:nutri_scan/domain/entities/meal_entry.dart';

double calculateCaloriesFromMealEntry(MealEntry entry) {
  double totalCalories = (entry.servingGrams / 100) * entry.nutriments.caloriesPer100g!;
  return totalCalories;
}