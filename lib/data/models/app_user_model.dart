import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';

/// Modelo de dados para conversão entre documentos do Firestore e a entidade [AppUser].
///
/// Responsável por:
/// - Converter um [DocumentSnapshot] do Firestore num [AppUser] (`fromDoc`).
/// - Converter um [AppUser] de volta para um mapa pronto para escrita no Firestore (`toMap`).
/// - Aplicar valores padrão seguros para campos ausentes ou mal formatados.
class AppUserModel {
  /// Converte um [DocumentSnapshot] do Firestore num [AppUser].
  ///
  /// Campos em falta recebem valores padrão:
  /// - `displayName` e `email` → string vazia.
  /// - `gender` → `Gender.other`.
  /// - `dateOfBirth` → 1 de janeiro de 2000.
  /// - `height` → 170 cm, `weight` → 70 kg.
  /// - `objective` → `Objective.maintainWeight`.
  /// - `nutritionGoals` → metas padrão (2000 kcal, 150 g proteína, 250 g hidratos, 65 g gordura, 2000 ml água).
  static AppUser fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    final goals = map['nutritionGoals'] as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      gender: Gender.values.byName(map['gender'] as String? ?? 'other'),
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime(2000),
      height: (map['height'] as num?)?.toInt() ?? 170,
      weight: (map['weight'] as num?)?.toDouble() ?? 70,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

  /// Converte um [AppUser] num mapa adequado para escrita no Firestore.
  ///
  /// O campo `createdAt` é sempre preenchido com [FieldValue.serverTimestamp].
  /// Campos com valor `null` (como `objective` ou `nutritionGoals`) são
  /// escritos como `null`, permitindo que o documento seja criado parcialmente
  /// e preenchido ao longo do fluxo de onboarding.
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