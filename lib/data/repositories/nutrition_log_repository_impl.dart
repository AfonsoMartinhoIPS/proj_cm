import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/meal_entry_model.dart';
import 'package:nutri_scan/data/models/nutrition_log_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/domain/repositories/nutrition_log_repository.dart';

/// Implementação do [NutritionLogRepository] que utiliza o Firestore.
///
/// Gere os documentos diários de nutrição na coleção `users/{uid}/nutrition_logs/{date}`,
/// suportando a adição, remoção e atualização de entradas, bem como o registo de água.
class NutritionLogRepositoryImpl implements NutritionLogRepository {
  final _db = FirebaseFirestore.instance;

  /// Converte um [NutritionGoals] num mapa compatível com o Firestore.
  ///
  /// Devolve `null` se as metas forem `null`, permitindo que o campo seja
  /// omitido na escrita em vez de ser sobrescrito com `null`.
  Map<String, dynamic>? _goalsMap(NutritionGoals? goals) {
    if (goals == null) return null;
    return {
      'calories': goals.calories,
      'protein': goals.protein,
      'carbs': goals.carbs,
      'fat': goals.fat,
      'water': goals.water,
    };
  }

  /// Obtém o [NutritionLog] correspondente ao dia [date] para o utilizador [uid].
  ///
  /// Devolve `null` se o documento não existir.
  @override
  Future<NutritionLog?> getLog(String uid, String date) async {
    logger.d('NutritionLogRepository: getLog for $uid on $date');
    final doc = await _db.doc(FirestorePaths.nutritionLog(uid, date)).get();
    logger.d('NutritionLogRepository: getLog doc exists=${doc.exists}');
    if (!doc.exists) return null;
    return NutritionLogModel.fromMap(doc.data()!);
  }

  /// Adiciona uma entrada de refeição ao registo do dia [date].
  ///
  /// Se o documento do dia ainda não existir, este é criado automaticamente
  /// com as metas congeladas fornecidas em [goalsSnapshot]. A entrada é
  /// anexada à lista existente através de `arrayUnion`.
  @override
  Future<void> addEntry(
    String uid,
    String date,
    MealEntry entry, {
    NutritionGoals? goalsSnapshot,
  }) async {
    logger.d('NutritionLogRepository: addEntry for $uid on $date');
    final docRef = _db.doc(FirestorePaths.nutritionLog(uid, date));
    final payload = <String, dynamic>{
      'date': date,
      'entries': FieldValue.arrayUnion([MealEntryModel.toMap(entry)]),
      'waterMl': FieldValue.increment(0),
    };
    final goalsMap = _goalsMap(goalsSnapshot);
    if (goalsMap != null) payload['goals'] = goalsMap;

    await docRef.set(payload, SetOptions(merge: true));
  }

  /// Remove a entrada com o [entryId] do registo do dia [date].
  ///
  /// Se o documento não existir, a operação é ignorada.
  @override
  Future<void> removeEntry(String uid, String date, String entryId) async {
    logger.d('NutritionLogRepository: removeEntry for $uid on $date');
    final doc = await _db.doc(FirestorePaths.nutritionLog(uid, date)).get();
    if (!doc.exists) return;
    final entries =
        List<Map<String, dynamic>>.from(doc.data()!['entries'] ?? []);
    entries.removeWhere((e) => e['id'] == entryId);
    await _db
        .doc(FirestorePaths.nutritionLog(uid, date))
        .update({'entries': entries});
  }

  /// Atualiza o total de água para o dia [date].
  ///
  /// Tal como [addEntry], cria o documento com as metas congeladas
  /// se este ainda não existir.
  @override
  Future<void> updateWater(
    String uid,
    String date,
    double waterMl, {
    NutritionGoals? goalsSnapshot,
  }) async {
    final payload = <String, dynamic>{
      'date': date,
      'waterMl': waterMl,
    };
    final goalsMap = _goalsMap(goalsSnapshot);
    if (goalsMap != null) payload['goals'] = goalsMap;

    await _db
        .doc(FirestorePaths.nutritionLog(uid, date))
        .set(payload, SetOptions(merge: true));
  }

  /// Substitui uma entrada existente (pelo [MealEntry.id]) pela nova [entry].
  ///
  /// Se o documento ou o identificador não existirem, a operação é ignorada.
  @override
  Future<void> updateEntry(String uid, String date, MealEntry entry) async {
    logger.d(
        'NutritionLogRepository: updateEntry ${entry.id} for $uid on $date');
    final docRef = _db.doc(FirestorePaths.nutritionLog(uid, date));
    final doc = await docRef.get();
    if (!doc.exists) return;
    final entries =
        List<Map<String, dynamic>>.from(doc.data()!['entries'] ?? []);
    final idx = entries.indexWhere((e) => e['id'] == entry.id);
    if (idx == -1) return;
    entries[idx] = MealEntryModel.toMap(entry);
    await docRef.update({'entries': entries});
  }

  /// Apaga completamente o documento do dia [date] para o utilizador [uid].
  @override
  Future<void> deleteLog(String uid, String date) async {
    logger.d('NutritionLogRepository: deleteLog for $uid on $date');
    await _db.doc(FirestorePaths.nutritionLog(uid, date)).delete();
  }

  /// Obtém uma lista de [NutritionLog] para as [dates] especificadas.
  ///
  /// Os documentos que não existirem são omitidos do resultado.
  @override
  Future<List<NutritionLog>> getLogs(String uid, List<String> dates) async {
    final futures = dates.map((date) => getLog(uid, date));
    final results = await Future.wait(futures);
    return results.whereType<NutritionLog>().toList();
  }
}