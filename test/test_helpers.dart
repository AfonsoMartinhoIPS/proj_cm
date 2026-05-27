// test/test_helpers.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_scan/data/datasources/open_food_facts_datasource.dart';
import 'package:nutri_scan/domain/repositories/auth_repository.dart';
import 'package:nutri_scan/domain/repositories/product_repository.dart';
import 'package:nutri_scan/domain/repositories/user_repository.dart';
import 'package:nutri_scan/domain/repositories/nutrition_log_repository.dart';

// ============================================================================
// Domain Repository Mocks
// ============================================================================

class MockProductRepository extends Mock implements ProductRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNutritionLogRepository extends Mock
    implements NutritionLogRepository {}

// ============================================================================
// Data Source Mocks
// ============================================================================

class MockOpenFoodFactsDatasource extends Mock
    implements OpenFoodFactsDatasource {}

// ============================================================================
// Common test setup utilities
// ============================================================================

/// Common setup for all tests (can be called from setUpAll)
Future<void> testSetUpAll() async {
  // Set up any global test configuration here
  // e.g., mock platform channels, initialize test logging
}

/// Teardown for all tests
Future<void> testTearDownAll() async {
  // Clean up global state if needed
}
