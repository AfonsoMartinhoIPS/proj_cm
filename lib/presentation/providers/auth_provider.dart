import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto/core/utils/logger.dart';
import 'package:projeto/data/repositories/auth_repository_impl.dart';
import 'package:projeto/data/repositories/user_repository_impl.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/presentation/providers/onboarding_provider.dart';


class AuthNotifier extends AsyncNotifier<AppUser?> {
  AuthRepositoryImpl authRepository = AuthRepositoryImpl();
  UserRepositoryImpl userRepository = UserRepositoryImpl();

  @override
  Future<AppUser?> build() async {
    logger.d('AuthNotifier: checking existing session');
    final uid = authRepository.getCurrentUser();
    if (uid == null) {
      logger.d('AuthNotifier: no active session');
      return null;
    }
    logger.d('AuthNotifier: session found, loading user $uid');
    return userRepository.getUser(uid);
  }

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
        state = AsyncValue.error('Conta não encontrada. Regista-te primeiro.', StackTrace.current);
        return;
      }
      logger.d('AuthNotifier: login success, user loaded: $uid');
      state = AsyncValue.data(user);
    } catch (e, st) {
      logger.e('AuthNotifier: login error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    logger.d('AuthNotifier: logging out');
    await authRepository.logout();
    logger.d('AuthNotifier: logged out, clearing state');
    state = const AsyncValue.data(null);
  }

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
        goals: onboarding.calculatedGoals,
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


final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(() => AuthNotifier());
