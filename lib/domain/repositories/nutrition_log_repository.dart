import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';

/// Contrato para operações de persistência dos registos diários de nutrição.
///
/// Define os métodos que qualquer implementação de repositório de registos
/// de nutrição deve fornecer: obter um dia específico, adicionar/remover
/// entradas, atualizar uma entrada, apagar um dia e registar o consumo de água.
abstract class NutritionLogRepository {
  /// Devolve o [NutritionLog] correspondente ao dia [date] para o utilizador
  /// [uid], ou `null` se o documento não existir.
  Future<NutritionLog?> getLog(String uid, String date);

  /// Adiciona uma [entry] ao registo do dia [date].
  ///
  /// Se o documento do dia ainda não existir, este é criado automaticamente.
  /// O parâmetro [goalsSnapshot] deve conter as metas nutricionais atuais do
  /// utilizador; estas são congeladas no documento para que alterações futuras
  /// às metas não afetem retroativamente dias históricos.
  Future<void> addEntry(
    String uid,
    String date,
    MealEntry entry, {
    NutritionGoals? goalsSnapshot,
  });

  /// Remove a entrada identificada por [entryId] do registo do dia [date].
  Future<void> removeEntry(String uid, String date, String entryId);

  /// Substitui uma entrada existente (identificada pelo [MealEntry.id]) pela
  /// nova [entry].
  ///
  /// Se o documento ou o identificador não existirem, a operação é ignorada.
  Future<void> updateEntry(String uid, String date, MealEntry entry);

  /// Apaga completamente o documento do dia [date] para o utilizador [uid].
  Future<void> deleteLog(String uid, String date);

  /// Define o total diário de água para o dia [date].
  ///
  /// Tal como [addEntry], cria o documento com as metas congeladas
  /// ([goalsSnapshot]) se este ainda não existir.
  Future<void> updateWater(
    String uid,
    String date,
    double waterMl, {
    NutritionGoals? goalsSnapshot,
  });

  /// Devolve uma lista de [NutritionLog] para as [dates] especificadas,
  /// pertencentes ao utilizador [uid].
  ///
  /// Os documentos que não existirem são omitidos do resultado.
  Future<List<NutritionLog>> getLogs(String uid, List<String> dates);
}