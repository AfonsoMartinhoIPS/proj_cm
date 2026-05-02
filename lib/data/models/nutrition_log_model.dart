import 'package:projeto/data/models/meal_entry_model.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/entities/nutrition_log.dart';


class NutritionLogModel {
  static NutritionLog fromMap(Map<String, dynamic> map) {
    return NutritionLog(
      date: map['date'] as String,
      entries: (map['entries'] as List<dynamic>).map((e) => MealEntryModel.fromMap(e as Map<String, dynamic>)).toList(),
      waterMl: (map['waterMl'] as num).toDouble(),
      goals: NutritionGoals(
        calories: (map['goals']['calories'] as num).toDouble(),
        protein: (map['goals']['protein'] as num).toDouble(),
        carbs: (map['goals']['carbs'] as num).toDouble(),
        fat: (map['goals']['fat'] as num).toDouble(),
        water: (map['goals']['water'] as num).toDouble(),
      ),
    );
  }

  static Map<String, dynamic> toMap(NutritionLog n) {
    return {
      'date': n.date,
      'entries': n.entries.map((e) => MealEntryModel.toMap(e)).toList(),
      'waterMl': n.waterMl,
      'goals': {
        'calories': n.goals.calories,
        'protein': n.goals.protein,
        'carbs': n.goals.carbs,
        'fat': n.goals.fat,
        'water': n.goals.water,
      },
    };
  }
}
