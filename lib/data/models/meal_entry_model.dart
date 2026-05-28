import 'package:nutri_scan/domain/entities/meal_entry.dart';

/// (De)serialisation for individual meal entries inside `nutrition_logs/{date}`.
///
/// The on-disk shape stores scaled-for-serving totals (kcal/g for the actual
/// consumed amount) rather than per-100g rates. This means any client reading
/// the doc just displays the numbers - no /100 math at read time. The scaling
/// is computed once in `AddMealScreen._submit` when the entry is created.
class MealEntryModel {
  static MealEntry fromMap(Map<String, dynamic> map) {
    final n = (map['nutriments'] as Map?) ?? const {};
    return MealEntry(
      id: map['id'] as String,
      productBarcode: map['productBarcode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImageUrl: map['productImageUrl'] as String?,
      mealType: MealType.values.firstWhere(
        (v) => v.name == map['mealType'],
        orElse: () => MealType.snack,
      ),
      servingGrams: (map['servingGrams'] as num?)?.toDouble() ?? 0,
      calories: (n['calories'] as num?)?.toDouble() ?? 0,
      protein:  (n['protein']  as num?)?.toDouble() ?? 0,
      carbs:    (n['carbs']    as num?)?.toDouble() ?? 0,
      fat:      (n['fat']      as num?)?.toDouble() ?? 0,
      loggedAt: _parseDate(map['loggedAt']),
    );
  }

  static Map<String, dynamic> toMap(MealEntry e) {
    return {
      'id': e.id,
      'productBarcode': e.productBarcode,
      'productName': e.productName,
      'productImageUrl': e.productImageUrl,
      'mealType': e.mealType.name,
      'servingGrams': e.servingGrams,
      // Already scaled for the consumed serving - readers display as-is.
      'nutriments': {
        'calories': e.calories,
        'protein': e.protein,
        'carbs': e.carbs,
        'fat': e.fat,
      },
      'loggedAt': e.loggedAt.toIso8601String(),
    };
  }

  /// Tolerates ISO-8601 strings and missing values. Falls back to "now" so
  /// a malformed legacy doc still renders.
  static DateTime _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
