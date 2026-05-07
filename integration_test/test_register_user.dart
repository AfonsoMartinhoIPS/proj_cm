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
    AppUser? user = await authRepository.register(email, password);
    logger.d("User signed up: ${user?.email}");

    expect(user, isNotNull);
  });
}
