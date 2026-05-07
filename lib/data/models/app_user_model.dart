import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/domain/entities/app_user.dart';

class AppUserModel {
  static AppUser fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    final goals = map['goals'] as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      goals: NutritionGoals(
        calories: (goals['calories'] as num?)?.toDouble() ?? 2000,
        protein: (goals['protein'] as num?)?.toDouble() ?? 150,
        carbs: (goals['carbs'] as num?)?.toDouble() ?? 250,
        fat: (goals['fat'] as num?)?.toDouble() ?? 65,
        water: (goals['water'] as num?)?.toDouble() ?? 2000,
      ),
    );
  }

  static Map<String, dynamic> toMap(AppUser u) {
    return {
      'displayName': u.displayName,
      'email': u.email,
      'createdAt': FieldValue.serverTimestamp(),
      'goals': {
        'calories': u.goals?.calories,
        'protein': u.goals?.protein,
        'carbs': u.goals?.carbs,
        'fat': u.goals?.fat,
        'water': u.goals?.water,
      },
    };
  }
}
