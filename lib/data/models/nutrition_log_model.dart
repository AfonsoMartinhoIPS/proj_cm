import 'package:nutri_scan/data/models/meal_entry_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';

/// Firestore (de)serialization for `nutrition_logs/{date}` docs.
class NutritionLogModel {
  /// Defaults used when a legacy doc has no `goals` snapshot. Same fallback
  /// values as NutritionLogsNotifier._emptyLog.
  static const _fallbackGoals = NutritionGoals(
    calories: 2000,
    protein: 150,
    carbs: 250,
    fat: 65,
    water: 2000,
  );

  /// Parses a Firestore doc map into a [NutritionLog]. Tolerant of missing or
  /// malformed fields - older docs created before the goals-snapshot refactor
  /// have no `goals` field and would otherwise crash. We default what's safe
  /// and skip what isn't (entries with non-map shape are filtered).
  static NutritionLog fromMap(Map<String, dynamic> map) {
    return NutritionLog(
      date: map['date'] as String? ?? '',
      entries: ((map['entries'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => MealEntryModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      waterMl: (map['waterMl'] as num?)?.toDouble() ?? 0,
      goals: _parseGoals(map['goals']),
    );
  }

  static NutritionGoals _parseGoals(dynamic raw) {
    if (raw is! Map) return _fallbackGoals;
    final goals = Map<String, dynamic>.from(raw);
    return NutritionGoals(
      calories: (goals['calories'] as num?)?.toDouble() ?? _fallbackGoals.calories,
      protein: (goals['protein'] as num?)?.toDouble() ?? _fallbackGoals.protein,
      carbs: (goals['carbs'] as num?)?.toDouble() ?? _fallbackGoals.carbs,
      fat: (goals['fat'] as num?)?.toDouble() ?? _fallbackGoals.fat,
      water: (goals['water'] as num?)?.toDouble() ?? _fallbackGoals.water,
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
