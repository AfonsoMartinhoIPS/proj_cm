import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/core/database/firestore_paths.dart';
import 'package:projeto/data/models/app_user_model.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/domain/repositories/user_repository.dart';

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
