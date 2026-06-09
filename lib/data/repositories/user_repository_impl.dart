// lib/data/repositories/user_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/app_user_model.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/repositories/user_repository.dart';

/// Implementação do [UserRepository] que utiliza o Firestore como backend.
///
/// Fornece métodos para obter, guardar e atualizar as metas nutricionais
/// de um utilizador, interagindo diretamente com a coleção `users` do Firestore.
class UserRepositoryImpl implements UserRepository {
  final _db = FirebaseFirestore.instance;

  /// Obtém o [AppUser] correspondente ao [uid] a partir do Firestore.
  ///
  /// Devolve `null` se o documento não existir.
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

  /// Guarda um [AppUser] no Firestore.
  ///
  /// Utiliza `merge: true` para preservar campos existentes que não estejam
  /// presentes no objeto fornecido. Antes de escrever, verifica se o
  /// documento já existe: caso contrário, instrui o [AppUserModel.toMap] a
  /// incluir `createdAt: serverTimestamp()` para registar o momento exato
  /// da criação. Em escritas subsequentes o campo é omitido, preservando o
  /// timestamp original.
  @override
  Future<void> saveUser(AppUser user) async {
    logger.d('Saving user to Firestore: ${user.uid} (${user.email})');
    final docRef = _db.doc(FirestorePaths.user(user.uid));
    final existing = await docRef.get();
    final isCreate = !existing.exists;
    await docRef.set(
      AppUserModel.toMap(user, isCreate: isCreate),
      SetOptions(merge: true),
    );
    logger.d('User saved successfully (isCreate=$isCreate): ${user.uid}');
  }

  /// Atualiza as metas nutricionais do utilizador identificado por [uid].
  ///
  /// Escreve diretamente os campos `calories`, `protein`, `carbs`, `fat`
  /// e `water` dentro do mapa `nutritionGoals` no documento do utilizador.
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