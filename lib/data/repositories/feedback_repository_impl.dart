import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/feedback_entry_model.dart';
import 'package:nutri_scan/domain/entities/feedback_entry.dart';
import 'package:nutri_scan/domain/repositories/feedback_repository.dart';

/// Implementação do [FeedbackRepository] usando Firestore como backend.
///
/// Grava cada submissão como um novo documento em [FirestorePaths.feedback]
/// com id auto-gerado. Não lê de volta — feedback é uma escrita única
/// fire-and-forget do ponto de vista do utilizador.
class FeedbackRepositoryImpl implements FeedbackRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    logger.d('FeedbackRepository: submit from ${entry.uid}');
    await _db
        .collection(FirestorePaths.feedback)
        .add(FeedbackEntryModel.toMap(entry));
    logger.d('FeedbackRepository: submitted');
  }
}
