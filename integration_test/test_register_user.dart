import 'package:projeto/core/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto/core/database/database.dart';
import 'package:projeto/data/repositories/auth_repository_impl.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/repositories/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDatabase();
  });

  testWidgets('Fetch product from OpenFoodAPI', (tester) async {
    AuthRepository authRepository = AuthRepositoryImpl();

    // Sign up a new user
    final email = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'password';

    Map<String, dynamic> newUser = {
      'email': email,
      'password': password,
      'displayName': 'Test User',
      'dateOfBirth': DateTime(1990, 1, 1),
      'gender': Gender.male,
      'weight': 70,
      'height': 180,
    };

    AppUser? user = await authRepository.register(
      email: newUser['email'],
      password: newUser['password'],
      displayName: newUser['displayName'],
      dateOfBirth: newUser['dateOfBirth'],
      gender: Gender.male,
      weight: 70,
      height: 180,
    );
    logger.d("User signed up: ${user?.email}");

    expect(user, isNotNull);
  });
}
