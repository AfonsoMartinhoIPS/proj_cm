import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nutri_scan/core/database/firestore_paths.dart';
import 'package:nutri_scan/data/models/app_user_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.doc(FirestorePaths.user(uid)).get();
    if (!doc.exists) return null;
    return AppUserModel.fromDoc(doc);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _db
        .doc(FirestorePaths.user(user.uid))
        .set(AppUserModel.toMap(user), SetOptions(merge: true));
  }

  @override
  Future<void> updateGoals(String uid, NutritionGoals goals) async {
    await _db.doc(FirestorePaths.user(uid)).update({
      'goals': {
        'calories': goals.calories,
        'protein': goals.protein,
        'carbs': goals.carbs,
        'fat': goals.fat,
        'water': goals.water,
      },
    });
  }
}
