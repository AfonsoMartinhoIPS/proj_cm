import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/meal_entry_model.dart';
import 'package:nutri_scan/data/models/nutrition_log_model.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/domain/repositories/nutrition_log_repository.dart';

class NutritionLogRepositoryImpl implements NutritionLogRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<NutritionLog?> getLog(String uid, String date) async {
    final doc = await _db.doc(FirestorePaths.nutritionLog(uid, date)).get();
    if (!doc.exists) return null;
    return NutritionLogModel.fromMap(doc.data()!);
  }

  @override
  Future<void> addEntry(String uid, String date, MealEntry entry) async {
    final ref = _db.doc(FirestorePaths.nutritionLog(uid, date));
    await ref.set({
      'date': date,
      'entries': FieldValue.arrayUnion([MealEntryModel.toMap(entry)]),
      'waterMl': FieldValue.increment(0),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeEntry(String uid, String date, String entryId) async {
    final doc = await _db.doc(FirestorePaths.nutritionLog(uid, date)).get();
    if (!doc.exists) return;
    final entries = List<Map<String, dynamic>>.from(doc.data()!['entries'] ?? []);
    entries.removeWhere((e) => e['id'] == entryId);
    await _db.doc(FirestorePaths.nutritionLog(uid, date)).update({'entries': entries});
  }

  @override
  Future<void> updateWater(String uid, String date, double waterMl) async {
    await _db.doc(FirestorePaths.nutritionLog(uid, date)).set(
      {'date': date, 'waterMl': waterMl},
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<NutritionLog>> getLogs(String uid, List<String> dates) async {
    final futures = dates.map((date) => getLog(uid, date));
    final results = await Future.wait(futures);
    return results.whereType<NutritionLog>().toList();
  }
}
