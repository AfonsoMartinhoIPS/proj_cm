import 'package:nutri_scan/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Future<void> saveUser(AppUser user);
  Future<void> updateGoals(String uid, NutritionGoals goals);
}
