// lib/data/models/nutriments_model.dart

import 'package:nutri_scan/domain/entities/nutriments.dart';

/// Modelo de dados para conversão entre mapas e a entidade [Nutriments].
///
/// Responsável por:
/// - Converter um mapa genérico (vindo do Firestore ou de uma API externa) num [Nutriments] (`fromMap`).
/// - Converter um [Nutriments] de volta para um mapa pronto para serialização (`toMap`).
class NutrimentsModel {
  /// Converte um [Map<String, dynamic>] num [Nutriments].
  ///
  /// Cada campo nutricional é extraído como `double?`. Campos ausentes ou
  /// com tipo inválido resultam em `null`.
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

  /// Converte um [Nutriments] num mapa adequado para escrita no Firestore.
  ///
  /// Cada campo nutricional é escrito como o valor original (`double?`),
  /// permitindo que campos `null` sejam armazenados como ausentes.
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