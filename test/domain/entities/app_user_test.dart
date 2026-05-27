// test/domain/entities/app_user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';

void main() {
  group('AppUser Entity Tests', () {
    late AppUser appUser;
    late NutritionGoals nutritionGoals;

    setUp(() {
      nutritionGoals = const NutritionGoals(
        calories: 2500,
        protein: 150,
        carbs: 300,
        fat: 80,
        water: 2500,
      );

      appUser = AppUser(
        uid: 'test-user-123',
        displayName: 'Test User',
        dateOfBirth: DateTime(2000, 1, 15),
        gender: Gender.male,
        height: 180,
        weight: 75.0,
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        nutritionGoals: nutritionGoals,
        objective: Objective.maintainWeight,
      );
    });

    test('AppUser should be created with correct values', () {
      expect(appUser.uid, 'test-user-123');
      expect(appUser.displayName, 'Test User');
      expect(appUser.email, 'test@example.com');
      expect(appUser.gender, Gender.male);
      expect(appUser.height, 180);
      expect(appUser.weight, 75.0);
    });

    test('AppUser with female gender', () {
      final femaleUser = AppUser(
        uid: 'user-2',
        displayName: 'Female User',
        dateOfBirth: DateTime(1995, 5, 20),
        gender: Gender.female,
        height: 165,
        weight: 60.0,
        email: 'female@example.com',
        createdAt: DateTime(2024, 1, 1),
        nutritionGoals: const NutritionGoals(
          calories: 2000,
          protein: 120,
          carbs: 250,
          fat: 65,
          water: 2000,
        ),
        objective: Objective.maintainWeight,
      );

      expect(femaleUser.gender, Gender.female);
    });

    test('AppUser with other gender', () {
      final otherUser = AppUser(
        uid: 'user-3',
        displayName: 'Other User',
        dateOfBirth: DateTime(1990, 3, 10),
        gender: Gender.other,
        height: 175,
        weight: 70.0,
        email: 'other@example.com',
        createdAt: DateTime(2024, 1, 1),
        nutritionGoals: const NutritionGoals(
          calories: 2500,
          protein: 150,
          carbs: 300,
          fat: 80,
          water: 2500,
        ),
        objective: Objective.loseWeight,
      );

      expect(otherUser.gender, Gender.other);
    });

    test('AppUser nutritionGoals can be null', () {
      final userNoGoals = AppUser(
        uid: 'user-4',
        displayName: 'No Goals User',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: Gender.male,
        height: 170,
        weight: 70.0,
        email: 'nogoals@example.com',
        createdAt: DateTime.now(),
        nutritionGoals: null,
        objective: Objective.gainWeight,
      );

      expect(userNoGoals.nutritionGoals, isNull);
    });

    test('NutritionGoals should store all macro and hydration data', () {
      expect(nutritionGoals.calories, 2500);
      expect(nutritionGoals.protein, 150);
      expect(nutritionGoals.carbs, 300);
      expect(nutritionGoals.fat, 80);
      expect(nutritionGoals.water, 2500);
    });
  });

  group('Gender Enum Tests', () {
    test('All Gender values exist', () {
      expect(Gender.male, isNotNull);
      expect(Gender.female, isNotNull);
      expect(Gender.other, isNotNull);
    });

    test('All Gender values are unique', () {
      final values = Gender.values;
      expect(values.length, 3);
      expect(values.toSet().length, 3);
    });

    test('Gender can be compared', () {
      expect(Gender.male == Gender.male, isTrue);
      expect(Gender.male == Gender.female, isFalse);
    });
  });

  group('Objective Enum Tests', () {
    test('Objective.loseWeight has correct label', () {
      expect(Objective.loseWeight.label, 'Perder peso');
    });

    test('Objective.maintainWeight has correct label', () {
      expect(Objective.maintainWeight.label, 'Manter peso');
    });

    test('Objective.gainWeight has correct label', () {
      expect(Objective.gainWeight.label, 'Ganhar peso');
    });

    test('All Objective values are unique', () {
      final values = Objective.values;
      expect(values.length, 3);
      expect(values.toSet().length, 3);
    });
  });
}
