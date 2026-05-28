import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/meal_entry_model.dart';
import 'package:nutri_scan/data/models/nutrition_log_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/domain/repositories/nutrition_log_repository.dart';

class NutritionLogRepositoryImpl implements NutritionLogRepository {
  final _db = FirebaseFirestore.instance;

  /// Serialise a [NutritionGoals] to a Firestore-friendly map.
  /// Returns `null` when no goals are provided so the caller can skip writing
  /// the field entirely (and therefore avoid clobbering an existing snapshot
  /// with a null).
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

  @override
  Future<NutritionLog?> getLog(String uid, String date) async {
    logger.d('NutritionLogRepository: getLog for $uid on $date');
    final doc = await _db.doc(FirestorePaths.nutritionLog(uid, date)).get();
    logger.d('NutritionLogRepository: getLog doc exists=${doc.exists}');
    if (!doc.exists) return null;
    return NutritionLogModel.fromMap(doc.data()!);
  }

  /// Appends [entry] to the day's log.
  ///
  /// Single Firestore write via `set(..., merge: true)`:
  ///   - When the doc is missing → creates it with date + goals snapshot +
  ///     waterMl=0 + entries=[entry].
  ///   - When the doc exists → merges (arrayUnion appends entry, waterMl
  ///     untouched, goals re-written with the same map).
  ///
  /// The `goals` field is included on every call so the doc has a consistent
  /// shape from creation onwards. The provider passes the user's current
  /// goals - to keep history truly immutable across goal edits we'd need a
  /// transaction that only writes goals on first creation, but for the
  /// student-project scope this is fine.
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
      // `increment(0)` initialises waterMl to 0 on first create, no-op
      // otherwise.
      'waterMl': FieldValue.increment(0),
    };
    final goalsMap = _goalsMap(goalsSnapshot);
    if (goalsMap != null) payload['goals'] = goalsMap;

    await docRef.set(payload, SetOptions(merge: true));
  }

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

  /// Same lazy-create pattern as [addEntry] - handles the case where the
  /// first interaction of the day is logging water (no meal yet).
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

  @override
  Future<void> updateEntry(String uid, String date, MealEntry entry) async {
    logger.d('NutritionLogRepository: updateEntry ${entry.id} for $uid on $date');
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

  @override
  Future<void> deleteLog(String uid, String date) async {
    logger.d('NutritionLogRepository: deleteLog for $uid on $date');
    await _db.doc(FirestorePaths.nutritionLog(uid, date)).delete();
  }

  @override
  Future<List<NutritionLog>> getLogs(String uid, List<String> dates) async {
    final futures = dates.map((date) => getLog(uid, date));
    final results = await Future.wait(futures);
    return results.whereType<NutritionLog>().toList();
  }
}
