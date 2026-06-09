// test/fixtures/user_fixtures.dart
import 'package:nutri_scan/domain/entities/app_user.dart';

/// Factory for creating test AppUser entities
class UserFixtures {
  static AppUser createTestUser({
    String uid = 'test-user-123',
    String displayName = 'Test User',
    String email = 'test@example.com',
    DateTime? dateOfBirth,
    Gender gender = Gender.male,
    int height = 180,
    double weight = 75.0,
    NutritionGoals? nutritionGoals,
    Objective objective = Objective.maintainWeight,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName,
      dateOfBirth: dateOfBirth ?? DateTime(2000, 1, 1),
      gender: gender,
      height: height,
      weight: weight,
      email: email,
      createdAt: DateTime.now(),
      nutritionGoals:
          nutritionGoals ??
          const NutritionGoals(
            calories: 2500,
            protein: 150,
            carbs: 300,
            fat: 80,
            water: 2500,
          ),
      objective: objective,
    );
  }

  static NutritionGoals createTestNutritionGoals({
    double calories = 2500,
    double protein = 150,
    double carbs = 300,
    double fat = 80,
    double water = 2500,
  }) {
    return NutritionGoals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      water: water,
    );
  }
}
