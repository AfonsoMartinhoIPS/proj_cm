// test/domain/entities/nutriments_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';

void main() {
  group('Nutriments Calculation Tests', () {
    late Nutriments nutriments;

    setUp(() {
      nutriments = const Nutriments(
        caloriesPer100g: 500,
        carbsPer100g: 60,
        sugarsPer100g: 20,
        fatPer100g: 25,
        saturatedFatPer100g: 8,
        proteinPer100g: 15,
        saltPer100g: 2,
        fiberPer100g: 4,
      );
    });

    group('Calorie calculations', () {
      test('calories() returns correct value for 100g serving', () {
        final cal = nutriments.calories(grams: 100);
        expect(cal, 500.0);
      });

      test('calories() returns correct value for 50g serving', () {
        final cal = nutriments.calories(grams: 50);
        expect(cal, 250.0);
      });

      test('calories() returns zero when caloriesPer100g is null', () {
        final emptyNutriments = const Nutriments(caloriesPer100g: null);
        final cal = emptyNutriments.calories(grams: 100);
        expect(cal, 0.0);
      });

      test('calories() handles fractional grams', () {
        final cal = nutriments.calories(grams: 33.33);
        expect(cal, closeTo(166.65, 0.01));
      });
    });

    group('Carbohydrate calculations', () {
      test('carbs() returns correct value for 100g serving', () {
        final carbs = nutriments.carbs(grams: 100);
        expect(carbs, 60.0);
      });

      test('carbs() returns correct value for 200g serving', () {
        final carbs = nutriments.carbs(grams: 200);
        expect(carbs, 120.0);
      });

      test('carbs() returns zero when carbsPer100g is null', () {
        final emptyNutriments = const Nutriments(carbsPer100g: null);
        final carbs = emptyNutriments.carbs(grams: 100);
        expect(carbs, 0.0);
      });
    });

    group('Fat calculations', () {
      test('fat() returns correct value for 100g serving', () {
        final fat = nutriments.fat(grams: 100);
        expect(fat, 25.0);
      });

      test('fat() returns correct value for 75g serving', () {
        final fat = nutriments.fat(grams: 75);
        expect(fat, 18.75);
      });

      test('fat() returns zero when fatPer100g is null', () {
        final emptyNutriments = const Nutriments(fatPer100g: null);
        final fat = emptyNutriments.fat(grams: 100);
        expect(fat, 0.0);
      });
    });

    group('Protein calculations', () {
      test('protein() returns correct value for 100g serving', () {
        final protein = nutriments.protein(grams: 100);
        expect(protein, 15.0);
      });

      test('protein() returns correct value for 150g serving', () {
        final protein = nutriments.protein(grams: 150);
        expect(protein, 22.5);
      });

      test('protein() returns zero when proteinPer100g is null', () {
        final emptyNutriments = const Nutriments(proteinPer100g: null);
        final protein = emptyNutriments.protein(grams: 100);
        expect(protein, 0.0);
      });
    });

    group('Sugar calculations', () {
      test('sugars() returns correct value for 100g serving', () {
        final sugars = nutriments.sugars(grams: 100);
        expect(sugars, 20.0);
      });

      test('sugars() returns correct value for 250g serving', () {
        final sugars = nutriments.sugars(grams: 250);
        expect(sugars, 50.0);
      });

      test('sugars() returns zero when sugarsPer100g is null', () {
        final emptyNutriments = const Nutriments(sugarsPer100g: null);
        final sugars = emptyNutriments.sugars(grams: 100);
        expect(sugars, 0.0);
      });
    });

    group('Salt calculations', () {
      test('salt() returns correct value for 100g serving', () {
        final salt = nutriments.salt(grams: 100);
        expect(salt, 2.0);
      });

      test('salt() returns correct value for 50g serving', () {
        final salt = nutriments.salt(grams: 50);
        expect(salt, 1.0);
      });

      test('salt() returns zero when saltPer100g is null', () {
        final emptyNutriments = const Nutriments(saltPer100g: null);
        final salt = emptyNutriments.salt(grams: 100);
        expect(salt, 0.0);
      });
    });

    group('Edge cases', () {
      test('Nutriments with all null values handles calculations', () {
        final emptyNutriments = const Nutriments();
        expect(emptyNutriments.calories(grams: 100), 0.0);
        expect(emptyNutriments.carbs(grams: 100), 0.0);
        expect(emptyNutriments.fat(grams: 100), 0.0);
        expect(emptyNutriments.protein(grams: 100), 0.0);
        expect(emptyNutriments.sugars(grams: 100), 0.0);
        expect(emptyNutriments.salt(grams: 100), 0.0);
      });

      test('Nutriments calculation with zero grams returns zero', () {
        expect(nutriments.calories(grams: 0), 0.0);
        expect(nutriments.carbs(grams: 0), 0.0);
        expect(nutriments.protein(grams: 0), 0.0);
      });

      test('Nutriments calculation with negative grams', () {
        // This should ideally be caught, but test current behavior
        final cal = nutriments.calories(grams: -100);
        expect(cal, -500.0);
      });
    });
  });
}
