import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/app_user_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getUser(String uid) async {
    logger.d('Fetching user from Firestore: $uid');
    final doc = await _db.doc(FirestorePaths.user(uid)).get();
    if (!doc.exists) {
      logger.w('User doc not found for uid: $uid');
      return null;
    }
    logger.d('User fetched successfully: $uid');
    return AppUserModel.fromDoc(doc);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    logger.d('Saving user to Firestore: ${user.uid} (${user.email})');
    await _db
        .doc(FirestorePaths.user(user.uid))
        .set(AppUserModel.toMap(user), SetOptions(merge: true));
    logger.d('User saved successfully: ${user.uid}');
  }

  @override
  Future<void> updateGoals(String uid, NutritionGoals goals) async {
    logger.d('Updating goals for user: $uid');
    await _db.doc(FirestorePaths.user(uid)).update({
      'nutritionGoals': {
        'calories': goals.calories,
        'protein': goals.protein,
        'carbs': goals.carbs,
        'fat': goals.fat,
        'water': goals.water,
      },
    });
    logger.d('Goals updated for user: $uid');
  }
}
