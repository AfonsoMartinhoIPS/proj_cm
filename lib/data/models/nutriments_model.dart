import 'package:projeto/domain/entities/nutriments.dart';

class NutrimentsModel {
  static Nutriments fromMap(Map<String, dynamic> map) {
    return Nutriments(
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble(),
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble(),
      sugarsPer100g: (map['sugarsPer100g'] as num?)?.toDouble(),
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble(),
      saturatedFatPer100g: (map['saturatedFatPer100g'] as num?)?.toDouble(),
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble(),
      saltPer100g: (map['saltPer100g'] as num?)?.toDouble(),
      fiberPer100g: (map['fiberPer100g'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> toMap(Nutriments n) {
    return {
      'caloriesPer100g': n.caloriesPer100g,
      'carbsPer100g': n.carbsPer100g,
      'sugarsPer100g': n.sugarsPer100g,
      'fatPer100g': n.fatPer100g,
      'saturatedFatPer100g': n.saturatedFatPer100g,
      'proteinPer100g': n.proteinPer100g,
      'saltPer100g': n.saltPer100g,
      'fiberPer100g': n.fiberPer100g,
    };
  }
}
