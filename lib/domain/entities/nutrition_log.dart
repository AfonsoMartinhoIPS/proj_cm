// lib/domain/entities/nutrition_log.dart

import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';

/// Registo diário de nutrição.
///
/// Agrega todas as entradas de refeição de um dia, o total de água consumida
/// e uma snapshot das metas nutricionais que estavam ativas nesse dia.
class NutritionLog {
  /// Data do registo no formato `YYYY-MM-DD`.
  final String date;

  /// Lista de entradas de refeição registadas neste dia.
  final List<MealEntry> entries;

  /// Total de água consumida no dia, em mililitros.
  final double waterMl;

  /// Snapshot das metas nutricionais congeladas neste dia.
  ///
  /// Alterações futuras às metas do utilizador não afetam este valor,
  /// preservando o contexto histórico.
  final NutritionGoals goals;

  /// Cria um [NutritionLog].
  ///
  /// Todos os parâmetros são obrigatórios.
  const NutritionLog({
    required this.date,
    required this.entries,
    required this.waterMl,
    required this.goals,
  });

  /// Soma das calorias de todas as entradas do dia.
  ///
  /// Como cada [MealEntry] já armazena os valores escalados à porção
  /// consumida, basta somar os valores para obter o total diário.
  double get totalCalories => entries.fold(0, (s, e) => s + e.calories);

  /// Soma das proteínas de todas as entradas do dia (em gramas).
  double get totalProtein => entries.fold(0, (s, e) => s + e.protein);

  /// Soma dos hidratos de carbono de todas as entradas do dia (em gramas).
  double get totalCarbs => entries.fold(0, (s, e) => s + e.carbs);

  /// Soma das gorduras de todas as entradas do dia (em gramas).
  double get totalFat => entries.fold(0, (s, e) => s + e.fat);
}