import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';

class AppUserModel {
  static AppUser fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    final goals = map['nutritionGoals'] as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      gender: Gender.values.byName(map['gender'] as String? ?? 'other'),
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime(2000),
      height: (map['height'] as num?)?.toInt() ?? 170,
      weight: (map['weight'] as num?)?.toDouble() ?? 70,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      objective: Objective.values.firstWhere(
        (o) => o.name == (map['objective'] as String?),
        orElse: () => Objective.maintainWeight,
      ),
      nutritionGoals: NutritionGoals(
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
      'gender': u.gender.name,
      'dateOfBirth': Timestamp.fromDate(u.dateOfBirth),
      'height': u.height,
      'weight': u.weight,
      'objective': u.objective?.name,
      'nutritionGoals': {
        'calories': u.nutritionGoals?.calories,
        'protein': u.nutritionGoals?.protein,
        'carbs': u.nutritionGoals?.carbs,
        'fat': u.nutritionGoals?.fat,
        'water': u.nutritionGoals?.water,
      },
    };
  }
}
