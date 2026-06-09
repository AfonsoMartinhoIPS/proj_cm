// lib/domain/repositories/user_repository.dart

import 'package:nutri_scan/domain/entities/app_user.dart';

/// Contrato para operações de persistência do utilizador.
///
/// Define os métodos que qualquer implementação de repositório de utilizadores
/// deve fornecer: obter um utilizador pelo identificador, guardar um novo
/// utilizador e atualizar as metas nutricionais.
abstract class UserRepository {
  /// Devolve o [AppUser] correspondente ao [uid] ou `null` se não existir.
  Future<AppUser?> getUser(String uid);

  /// Persiste um novo [AppUser] no sistema de armazenamento.
  Future<void> saveUser(AppUser user);

  /// Atualiza apenas as metas nutricionais do utilizador identificado por [uid].
  Future<void> updateGoals(String uid, NutritionGoals goals);
}