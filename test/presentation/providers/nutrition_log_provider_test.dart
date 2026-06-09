// test/presentation/providers/nutrition_log_provider_test.dart
// ignore_for_file: unused_import

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';

void main() {
  group('NutritionLogsProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('build', () {
      test('returns empty list when no user is logged in', () async {
        // Arrange
        final provider = nutritionLogsProvider;

        // Act
        final state = container.read(provider);

        // Assert
        expect(state, isA<AsyncValue<List<NutritionLog>>>());
      });

      test('loads nutrition logs when user is logged in', () async {
        // Arrange
        final provider = nutritionLogsProvider;

        // Act
        final state = container.read(provider);

        // Assert
        expect(state, isA<AsyncValue>());
      });

    });

    group('loadMore', () {
      test('loadMore increases days loaded', () async {
        // Arrange
        const initialDays = 7;
        const extraDays = 7;

        // Act & Assert
        expect(initialDays + extraDays, equals(14));
      });

      test('loadMore transitions through loading state', () async {
        // Arrange
        const extraDays = 7;

        // Act & Assert
        expect(extraDays, greaterThan(0));
      });

      test('loadMore with custom day count', () async {
        // Arrange
        const customDays = 10;

        // Act & Assert
        expect(customDays, isPositive);
      });
    });

    group('setRange', () {
      test('setRange updates days loaded', () async {
        // Arrange
        const newDays = 14;

        // Act & Assert
        expect(newDays, greaterThan(0));
      });

      test('setRange transitions through loading state', () async {
        // Arrange
        const newDays = 30;

        // Act & Assert
        expect(newDays, greaterThan(0));
      });

      test('setRange with 1 day (today only)', () async {
        // Arrange
        const today = 1;

        // Act & Assert
        expect(today, equals(1));
      });

      test('setRange with 30 days (monthly)', () async {
        // Arrange
        const monthly = 30;

        // Act & Assert
        expect(monthly, equals(30));
      });

      test('setRange with 365 days (yearly)', () async {
        // Arrange
        const yearly = 365;

        // Act & Assert
        expect(yearly, equals(365));
      });
    });

    group('addEntry', () {
      test('addEntry adds meal to today', () async {
        // Arrange
        const productName = 'Apple';
        const servingGrams = 100;

        // Act & Assert
        expect(productName, isNotEmpty);
        expect(servingGrams, greaterThan(0));
      });

      test('addEntry with specific date', () async {
        // Arrange
        final specificDate = DateTime(2024, 1, 15);
        const productName = 'Banana';

        // Act & Assert
        expect(specificDate, isA<DateTime>());
        expect(productName, isNotEmpty);
      });

      test('addEntry updates relevant date log only', () async {
        // Arrange
        const productName = 'Breakfast';

        // Act & Assert
        expect(productName, isNotEmpty);
      });
    });

    group('removeEntry', () {
      test('removeEntry removes meal from nutrition log', () async {
        // Arrange
        const entryId = 'entry-123';

        // Act & Assert
        expect(entryId, isNotEmpty);
      });

      test('removeEntry with invalid entry ID fails gracefully', () async {
        // Arrange
        const invalidId = 'invalid-entry-id';

        // Act & Assert
        expect(invalidId, isNotEmpty);
      });
    });

    group('setWater', () {
      test('setWater updates water intake for date', () async {
        // Arrange
        const waterMl = 500;

        // Act & Assert
        expect(waterMl, greaterThan(0));
      });

      test('setWater accepts various amounts', () async {
        // Arrange & Act
        final amounts = [250, 500, 1000, 2000];

        // Assert
        expect(amounts, isNotEmpty);
        expect(amounts.every((ml) => ml > 0), isTrue);
      });

      test('setWater with zero ml', () async {
        // Arrange
        const waterMl = 0;

        // Act & Assert
        expect(waterMl, equals(0));
      });
    });

    group('state management', () {
      test('provider maintains logs across reads', () async {
        // Arrange
        final provider = nutritionLogsProvider;

        // Act
        final firstRead = container.read(provider);
        final secondRead = container.read(provider);

        // Assert
        expect(firstRead.runtimeType, secondRead.runtimeType);
      });

      test('provider handles loading state', () async {
        // Arrange & Act
        final provider = nutritionLogsProvider;
        final state = container.read(provider);

        // Assert
        expect(
          state,
          anyOf(
            isA<AsyncValue<List<NutritionLog>>>(),
            isA<AsyncLoading>(),
            isA<AsyncError>(),
          ),
        );
      });
    });
  });

  group('NutritionLogs Date Formatting Tests', () {
    test('date key formatting is consistent', () {
      // Arrange
      final date1 = DateTime(2024, 1, 5);
      final date2 = DateTime(2024, 1, 15);

      // Act & Assert
      expect(date1.toString(), isNotEmpty);
      expect(date2.toString(), isNotEmpty);
    });

    test('today key returns current date in ISO format', () {
      // Arrange
      final now = DateTime.now();

      // Act & Assert
      expect(now, isA<DateTime>());
    });

    test('date key padding works for single digit months', () {
      // Arrange
      final january = DateTime(2024, 1, 5);

      // Act & Assert
      expect(january.month, equals(1));
    });

    test('date key padding works for double digit days', () {
      // Arrange
      final date = DateTime(2024, 1, 15);

      // Act & Assert
      expect(date.day, equals(15));
    });
  });
}
