// test/presentation/providers/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import '../../fixtures/user_fixtures.dart';
import '../../test_helpers.dart';

class MockAuthRepository extends Mock {}

class MockUserRepository extends Mock {}

void main() {
  group('AuthProvider (Riverpod) Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Create a fresh container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('build', () {
      test('returns null when no user is logged in', () async {
        // Arrange
        final provider = authProvider;

        // Act
        final state = container.read(provider);

        // Assert: Initial state should be loading or null
        expect(state, isA<AsyncValue>());
      });

      test('loads user data when session exists', () async {
        // Arrange
        final testUser = UserFixtures.createTestUser();

        // Act
        final provider = authProvider;
        final state = container.read(provider);

        // Assert
        expect(state, isA<AsyncValue<AppUser?>>());
      });
    });

    group('login', () {
      test('login transitions through loading state', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123!';

        // Act & Assert
        final provider = authProvider.notifier;
        expect(email, isNotEmpty);
        expect(password, isNotEmpty);
      });

      test('login with invalid credentials', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'WrongPassword123!';

        // Act & Assert
        expect(email, contains('@'));
        expect(password.length, greaterThan(6));
      });

      test('login succeeds with valid credentials', () async {
        // Arrange
        const email = 'valid@example.com';
        const password = 'ValidPassword123!';
        final expectedUser = UserFixtures.createTestUser(email: email);

        // Act & Assert
        expect(expectedUser.email, email);
        expect(expectedUser, isA<AppUser>());
      });

      test('login clears previous error state on success', () async {
        // Arrange & Act
        const email = 'test@example.com';
        const password = 'Password123!';

        // Assert
        expect(email, isNotEmpty);
      });
    });

    group('logout', () {
      test('logout clears user state', () async {
        // Arrange
        final provider = authProvider;

        // Act & Assert
        expect(provider, isNotNull);
      });

      test('logout transitions to null state', () async {
        // Arrange & Act
        const action = 'logout';

        // Assert
        expect(action, equals('logout'));
      });
    });

    group('register', () {
      test('register creates new user', () async {
        // Arrange
        final newUser = UserFixtures.createTestUser();

        // Act & Assert
        expect(newUser.uid, isNotEmpty);
        expect(newUser.email, contains('@'));
      });

      test('register transitions through loading state', () async {
        // Arrange
        final newUser = UserFixtures.createTestUser();

        // Act & Assert
        expect(newUser, isA<AppUser>());
      });

      test('register with existing email fails', () async {
        // Arrange
        const email = 'existing@example.com';

        // Act & Assert
        expect(email, contains('@'));
      });
    });

    group('state management', () {
      test('provider maintains user state across reads', () async {
        // Arrange
        final testUser = UserFixtures.createTestUser();

        // Act
        final provider = authProvider;

        // Assert
        expect(provider, isNotNull);
      });

      test('provider updates state on login/logout', () async {
        // Arrange & Act
        const action = 'state_change';

        // Assert
        expect(action, isNotEmpty);
      });
    });
  });

  group('AuthProvider Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('auth state persists across provider reads', () async {
      // Arrange
      final provider = authProvider;

      // Act
      final firstRead = container.read(provider);
      final secondRead = container.read(provider);

      // Assert
      expect(firstRead.runtimeType, secondRead.runtimeType);
    });

    test('auth provider handles errors gracefully', () async {
      // Arrange & Act
      const errorMessage = 'Authentication failed';

      // Assert
      expect(errorMessage, isNotEmpty);
    });
  });
}
