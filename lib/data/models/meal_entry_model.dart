// lib/data/models/meal_entry_model.dart

import 'package:nutri_scan/domain/entities/meal_entry.dart';

/// Modelo de dados para (des)serialização de entradas de refeição (`MealEntry`).
///
/// As entradas são armazenadas nos documentos `nutrition_logs/{date}` com os
/// totais nutricionais já escalados para a porção consumida (kcal e gramas
/// para a quantidade exata ingerida), e não os valores por 100 g. Isto permite
/// que qualquer cliente que leia o documento apenas exiba os números — sem
/// necessidade de cálculos no momento da leitura.
///
/// O escalonamento é feito uma única vez em `AddMealScreen._submit` quando a
/// entrada é criada.
class MealEntryModel {
  /// Converte um mapa genérico (geralmente obtido de um documento do Firestore)
  /// num [MealEntry].
  ///
  /// Lê os totais nutricionais do sub-mapa `nutriments`. Campos em falta
  /// ou com tipos inválidos recebem valores padrão (`0` para números,
  /// `MealType.snack` para o tipo de refeição, e a data/hora atual para
  /// o `loggedAt`).
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
      protein: (n['protein'] as num?)?.toDouble() ?? 0,
      carbs: (n['carbs'] as num?)?.toDouble() ?? 0,
      fat: (n['fat'] as num?)?.toDouble() ?? 0,
      loggedAt: _parseDate(map['loggedAt']),
    );
  }

  /// Converte um [MealEntry] num mapa adequado para escrita no Firestore.
  ///
  /// Os totais nutricionais já escalados são escritos dentro do sub-mapa
  /// `nutriments`. O campo `loggedAt` é serializado como uma string ISO‑8601.
  static Map<String, dynamic> toMap(MealEntry e) {
    return {
      'id': e.id,
      'productBarcode': e.productBarcode,
      'productName': e.productName,
      'productImageUrl': e.productImageUrl,
      'mealType': e.mealType.name,
      'servingGrams': e.servingGrams,
      'nutriments': {
        'calories': e.calories,
        'protein': e.protein,
        'carbs': e.carbs,
        'fat': e.fat,
      },
      'loggedAt': e.loggedAt.toIso8601String(),
    };
  }

  /// Analisa o campo `loggedAt` de forma defensiva.
  ///
  /// Aceita strings ISO‑8601. Se o campo estiver ausente, for inválido ou
  /// tiver um tipo inesperado, devolve a data/hora atual para evitar que
  /// um documento legado cause uma falha na leitura.
  static DateTime _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}