import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_scan/core/utils/logger.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/repositories/auth_repository.dart';

/// Implementação do [AuthRepository] que utiliza o Firebase Authentication.
///
/// Fornece métodos para verificar a sessão atual, iniciar sessão, registar
/// novos utilizadores e terminar a sessão.
class AuthRepositoryImpl implements AuthRepository {
  /// Devolve o identificador do utilizador atualmente autenticado,
  /// ou `null` se não existir uma sessão ativa.
  @override
  String? getCurrentUser() {
    logger.d('Getting current user from FirebaseAuth');
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Inicia sessão com [email] e [password].
  ///
  /// Devolve o identificador do utilizador autenticado ou `null` se as
  /// credenciais forem inválidas. Em caso de erro, relança a exceção
  /// [FirebaseAuthException].
  @override
  Future<String?> login(String email, String password) async {
    try {
      logger.d('Attempting to log in user with email: $email');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        logger.e('Login failed: No user found in credential.');
        return null;
      }

      logger.d('User logged in with UID: ${firebaseUser.uid}');
      return firebaseUser.uid;
    } on FirebaseAuthException catch (e) {
      logger.e('Login failed: ${e.message}');
      rethrow;
    }
  }

  /// Termina a sessão do utilizador atualmente autenticado.
  @override
  Future<void> logout() async {
    logger.d('Logging out user');
    await FirebaseAuth.instance.signOut();
  }

  /// Regista um novo utilizador com os dados fornecidos.
  ///
  /// Devolve um [AppUser] completo em caso de sucesso, ou `null` se o registo
  /// falhar.  As metas nutricionais e o objetivo de peso são definidos como
  /// `null` — esses valores são posteriormente preenchidos pelo fluxo de
  /// onboarding.
  @override
  Future<AppUser?> register({
    required String email,
    required String password,
    required String displayName,
    required DateTime dateOfBirth,
    required Gender gender,
    required double weight,
    required int height,
  }) async {
    try {
      logger.d('Attempting to register user with email: $email');
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        logger.e('User creation failed');
        return null;
      }

      await firebaseUser.updateDisplayName(displayName);
      logger.d('User created with UID: ${firebaseUser.uid}');

      return AppUser(
        uid: firebaseUser.uid,
        displayName: displayName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        createdAt: DateTime.now(),
        nutritionGoals: null,
        objective: null,
      );
    } on FirebaseAuthException catch (e) {
      logger.e('Registration failed: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Registration error: $e');
      rethrow;
    }
  }
}