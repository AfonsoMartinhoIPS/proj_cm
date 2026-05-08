import 'package:projeto/domain/entities/app_user.dart';

abstract class AuthRepository {
  String? getCurrentUser();
  Future<String?> login(String email, String password);
  Future<AppUser?> register({
    required String email,
    required String password,
    required String displayName,
    required DateTime dateOfBirth,
    required Gender gender,
    required double weight,
    required int height,
  });
  Future<void> logout();
}
