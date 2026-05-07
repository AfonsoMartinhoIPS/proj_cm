import 'package:projeto/domain/entities/app_user.dart';

abstract class AuthRepository {
  String? getCurrentUser();
  Future<AppUser?> register(String email, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
}
