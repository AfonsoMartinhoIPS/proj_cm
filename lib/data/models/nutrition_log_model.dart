import 'package:nutri_scan/data/models/meal_entry_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';

/// Modelo de dados para conversão entre documentos do Firestore e a entidade [NutritionLog].
///
/// Responsável por:
/// - Converter um mapa vindo do Firestore num [NutritionLog] (`fromMap`).
/// - Converter um [NutritionLog] de volta para um mapa pronto para escrita (`toMap`).
/// - Tratar documentos legados que não possuem o campo `goals`, aplicando metas padrão.
class NutritionLogModel {
  /// Metas nutricionais padrão utilizadas quando um documento legado não
  /// contém a snapshot de `goals`.
  static const _fallbackGoals = NutritionGoals(
    calories: 2000,
    protein: 150,
    carbs: 250,
    fat: 65,
    water: 2000,
  );

  /// Converte um mapa genérico (geralmente obtido de um documento do Firestore)
  /// num [NutritionLog].
  ///
  /// É tolerante a campos ausentes ou mal formatados:
  /// - Documentos sem `goals` recebem as metas padrão.
  /// - Entradas que não sejam mapas são ignoradas.
  /// - `waterMl` em falta é assumido como 0.
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

  /// Analisa o campo `goals` de forma defensiva.
  ///
  /// Se o campo não for um mapa, devolve as metas padrão. Campos numéricos
  /// ausentes ou inválidos também são substituídos pelos valores padrão.
  static NutritionGoals _parseGoals(dynamic raw) {
    if (raw is! Map) return _fallbackGoals;
    final goals = Map<String, dynamic>.from(raw);
    return NutritionGoals(
      calories:
          (goals['calories'] as num?)?.toDouble() ?? _fallbackGoals.calories,
      protein:
          (goals['protein'] as num?)?.toDouble() ?? _fallbackGoals.protein,
      carbs: (goals['carbs'] as num?)?.toDouble() ?? _fallbackGoals.carbs,
      fat: (goals['fat'] as num?)?.toDouble() ?? _fallbackGoals.fat,
      water: (goals['water'] as num?)?.toDouble() ?? _fallbackGoals.water,
    );
  }

  /// Converte um [NutritionLog] num mapa adequado para escrita no Firestore.
  ///
  /// As entradas são serializadas através de [MealEntryModel.toMap].
  /// O campo `goals` é sempre escrito como um mapa com as cinco chaves.
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