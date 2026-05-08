import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/core/utils/logger.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  @override
  String? getCurrentUser() {
    logger.d('Getting current user from FirebaseAuth');
    return FirebaseAuth.instance.currentUser?.uid;
  }

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

  @override
  Future<void> logout() async {
    logger.d('Logging out user');
    await FirebaseAuth.instance.signOut();
  }

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
        goals: null,
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
