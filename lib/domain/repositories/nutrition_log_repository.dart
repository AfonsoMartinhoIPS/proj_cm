import 'package:projeto/domain/entities/meal_entry.dart';
import 'package:projeto/domain/entities/nutrition_log.dart';

abstract class NutritionLogRepository {
  Future<NutritionLog?> getLog(String uid, String date);
  Future<void> addEntry(String uid, String date, MealEntry entry);
  Future<void> removeEntry(String uid, String date, String entryId);
  Future<void> updateWater(String uid, String date, double waterMl);
  Future<List<NutritionLog>> getLogs(String uid, List<String> dates);
}
