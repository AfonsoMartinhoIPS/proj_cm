import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';

abstract class NutritionLogRepository {
  Future<NutritionLog?> getLog(String uid, String date);

  /// Append [entry] to the day's log at `nutrition_logs/{date}`.
  ///
  /// If the log doc does not exist yet for that date it is created on the
  /// fly via `set(..., merge: true)`. [goalsSnapshot] should be the user's
  /// goals as of "today" — it gets frozen onto the doc so future goal edits
  /// do not retroactively change historical days.
  Future<void> addEntry(
    String uid,
    String date,
    MealEntry entry, {
    NutritionGoals? goalsSnapshot,
  });

  Future<void> removeEntry(String uid, String date, String entryId);

  /// Set the daily water total. Creates the doc with [goalsSnapshot] frozen in
  /// when missing, same as [addEntry].
  Future<void> updateWater(
    String uid,
    String date,
    double waterMl, {
    NutritionGoals? goalsSnapshot,
  });

  Future<List<NutritionLog>> getLogs(String uid, List<String> dates);
}
