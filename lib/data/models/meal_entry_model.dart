import 'package:projeto/domain/entities/meal_entry.dart';
import 'package:projeto/domain/entities/nutriments.dart';

class MealEntryModel {
  static MealEntry fromMap(Map<String, dynamic> map) {
    final n = map['nutriments'] as Map<String, dynamic>;
    return MealEntry(
      id: map['id'] as String,
      productBarcode: map['productBarcode'] as String,
      productName: map['productName'] as String,
      productImageUrl: map['productImageUrl'] as String?,
      mealType: MealType.values.firstWhere((v) => v.name == map['mealType']),
      servingGrams: (map['servingGrams'] as num).toDouble(),
      nutriments: Nutriments(
        caloriesPer100g: (n['calories'] as num?)?.toDouble(),
        proteinPer100g: (n['protein'] as num?)?.toDouble(),
        carbsPer100g: (n['carbs'] as num?)?.toDouble(),
        fatPer100g: (n['fat'] as num?)?.toDouble(),
      ),
      loggedAt: (map['loggedAt'] as String).isNotEmpty
          ? DateTime.parse(map['loggedAt'] as String)
          : DateTime.now(),
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
      'nutriments': {
        'calories': e.nutriments.calories(grams: e.servingGrams),
        'protein': e.nutriments.protein(grams: e.servingGrams),
        'carbs': e.nutriments.carbs(grams: e.servingGrams),
        'fat': e.nutriments.fat(grams: e.servingGrams),
      },
      'loggedAt': e.loggedAt.toIso8601String(),
    };
  }
}

