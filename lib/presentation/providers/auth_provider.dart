import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/repositories/auth_repository_impl.dart';
import 'package:nutri_scan/data/repositories/user_repository_impl.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

/// Notifier que gere o estado de autenticação do utilizador.
///
/// Expõe um [AppUser] quando o utilizador está autenticado, ou `null` quando
/// não existe sessão ativa.  Trata das operações de login, registo, atualização
/// de objetivos e logout, mantendo a sincronização com o Firestore e o
/// Firebase Auth.
class AuthNotifier extends AsyncNotifier<AppUser?> {
  AuthRepositoryImpl authRepository = AuthRepositoryImpl();
  UserRepositoryImpl userRepository = UserRepositoryImpl();

  /// Obtém o documento do utilizador a partir do [uid].
  ///
  /// Devolve `null` se o documento não existir no Firestore.
  Future<AppUser?> _getUser(String uid) async {
    try {
      logger.d("AuthNotifier: fetching user for uid: $uid");
      final user = await userRepository.getUser(uid);
      if (user == null) {
        logger.w('AuthNotifier: no Firestore doc for uid: $uid');
        return null;
      }
      logger.d('AuthNotifier: user loaded successfully: $uid');
      return user;
    } catch (e, st) {
      logger.e('AuthNotifier: error fetching user', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Constrói o estado inicial verificando se existe uma sessão ativa.
  ///
  /// Se existir, carrega o documento do utilizador correspondente; caso
  /// contrário, define o estado como `null`.
  @override
  Future<AppUser?> build() async {
    logger.d('AuthNotifier: checking existing session');
    state = const AsyncValue.loading();
    try {
      final uid = authRepository.getCurrentUser();
      if (uid == null) {
        logger.d('AuthNotifier: no existing session found');
        state = const AsyncValue.data(null);
        return null;
      }

      logger.d('AuthNotifier: existing session found, loading user: $uid');
      final user = await _getUser(uid);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      logger.e('AuthNotifier: error during build', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Inicia sessão com [email] e [password].
  ///
  /// Se as credenciais forem válidas, carrega o documento do utilizador e
  /// atualiza o estado.  Caso o documento não exista, faz logout automático
  /// e emite um erro.
  Future<void> login(String email, String password) async {
    logger.d('AuthNotifier: login attempt for $email');
    state = const AsyncValue.loading();
    try {
      final uid = await authRepository.login(email, password);
      if (uid == null) {
        logger.w('AuthNotifier: login returned null uid');
        state = const AsyncValue.data(null);
        return;
      }
      final user = await userRepository.getUser(uid);
      if (user == null) {
        logger.w('AuthNotifier: no Firestore doc for uid: $uid');
        await authRepository.logout();
        state = AsyncValue.error(
            'Conta não encontrada. Regista-te primeiro.', StackTrace.current);
        return;
      }
      logger.d('AuthNotifier: login success, user loaded: $uid');
      state = AsyncValue.data(user);
    } catch (e, st) {
      logger.e('AuthNotifier: login error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Atualiza as metas nutricionais do utilizador autenticado.
  ///
  /// Persiste as novas metas no Firestore e reflete a alteração no estado
  /// imediatamente através de [AppUser.copyWith].
  Future<void> updateGoals(NutritionGoals goals) async {
    final user = state.value;
    if (user == null) {
      logger.w('AuthNotifier: updateGoals called with no user');
      return;
    }
    logger.d('AuthNotifier: updating goals for ${user.uid}');
    try {
      await userRepository.updateGoals(user.uid, goals);
      state = AsyncValue.data(user.copyWith(nutritionGoals: goals));
    } catch (e, st) {
      logger.e('AuthNotifier: updateGoals error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Termina a sessão atual.
  ///
  /// Remove o estado de autenticação do Firebase Auth e limpa o estado
  /// exposto, passando a `null`.
  Future<void> logout() async {
    logger.d('AuthNotifier: logging out');
    await authRepository.logout();
    logger.d('AuthNotifier: logged out, clearing state');
    state = const AsyncValue.data(null);
  }

  /// Regista um novo utilizador com os dados de [onboarding].
  ///
  /// Cria a conta no Firebase Auth e, em seguida, guarda o documento do
  /// utilizador no Firestore, incluindo as metas nutricionais calculadas
  /// durante o onboarding.
  Future<void> register(OnboardingState onboarding) async {
    logger.d('AuthNotifier: register attempt for ${onboarding.email}');
    state = const AsyncValue.loading();
    try {
      final user = await authRepository.register(
        email: onboarding.email,
        password: onboarding.password,
        displayName: onboarding.name,
        dateOfBirth: onboarding.dateOfBirth ?? DateTime(2000),
        gender: onboarding.gender,
        weight: onboarding.weight,
        height: onboarding.height,
      );
      if (user == null) {
        logger.w('AuthNotifier: register returned null user');
        state = const AsyncValue.data(null);
        return;
      }

      final userWithGoals = AppUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        gender: user.gender,
        dateOfBirth: user.dateOfBirth,
        height: user.height,
        weight: user.weight,
        createdAt: user.createdAt,
        nutritionGoals: onboarding.nutritionGoals,
        objective: onboarding.objective,
      );
      await userRepository.saveUser(userWithGoals);
      logger.d('AuthNotifier: register success, user saved: ${user.uid}');
      state = AsyncValue.data(userWithGoals);
    } catch (e, st) {
      logger.e('AuthNotifier: register error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider que expõe o estado de autenticação do utilizador.
///
/// Utilizado por todo o sistema de rotas e ecrãs protegidos para determinar
/// se o utilizador está autenticado e para aceder aos seus dados.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(() => AuthNotifier());