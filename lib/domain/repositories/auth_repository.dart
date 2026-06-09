// lib/domain/repositories/auth_repository.dart

import 'package:nutri_scan/domain/entities/app_user.dart';

/// Contrato para operações de autenticação.
///
/// Define os métodos que qualquer implementação de repositório de autenticação
/// deve fornecer: obter o utilizador atualmente autenticado, iniciar sessão,
/// registar um novo utilizador e terminar a sessão.
abstract class AuthRepository {
  /// Devolve o identificador do utilizador atualmente autenticado,
  /// ou `null` se não existir uma sessão ativa.
  String? getCurrentUser();

  /// Inicia sessão com [email] e [password].
  ///
  /// Devolve o identificador do utilizador autenticado ou `null` se as
  /// credenciais forem inválidas.
  Future<String?> login(String email, String password);

  /// Regista um novo utilizador com os dados fornecidos.
  ///
  /// Devolve um [AppUser] completo em caso de sucesso, ou `null` se o registo
  /// falhar.
  Future<AppUser?> register({
    required String email,
    required String password,
    required String displayName,
    required DateTime dateOfBirth,
    required Gender gender,
    required double weight,
    required int height,
  });

  /// Termina a sessão do utilizador atualmente autenticado.
  Future<void> logout();
}