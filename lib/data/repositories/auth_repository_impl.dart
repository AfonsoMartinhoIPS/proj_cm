import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projeto/core/utils/logger.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {


  @override
  String? getCurrentUser() {
    logger.d('Getting current user from FirebaseAuth');
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /*
  @returns the uid of the logged in user, or null if login failed
  */
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
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        logger.e('Login failed: Invalid email or password.');
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    logger.d('Logging out user');
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<AppUser?> register(
    String email,
    String password,
  ) async {
    try {
      logger.d('Attempting to register user with email: $email');
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        logger.e('User creation failed');
        return null;
      }

      logger.d('User created with UID: ${firebaseUser.uid}');
      return AppUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? email,
        createdAt: DateTime.now(),
        goals: null,
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        logger.e('Registration failed: The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        logger.e('Registration failed: The account already exists for that email.');
      }
    } catch (e) {
      logger.e(e);
    }

    return null;
  }
}
