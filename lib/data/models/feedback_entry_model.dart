import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/domain/entities/feedback_entry.dart';

/// Serialização de [FeedbackEntry] para o Firestore.
///
/// Apenas `toMap` é fornecido — o cliente nunca lê feedback de volta, pelo
/// que não há `fromDoc`. O campo `createdAt` é preenchido pelo servidor via
/// [FieldValue.serverTimestamp] para garantir consistência de relógio
/// independente do dispositivo.
class FeedbackEntryModel {
  /// Converte [entry] num mapa pronto a gravar em `feedback/{auto-id}`.
  static Map<String, dynamic> toMap(FeedbackEntry entry) {
    return {
      'uid': entry.uid,
      'email': entry.email,
      'device': entry.device,
      'osVersion': entry.osVersion,
      'model': entry.model,
      'message': entry.message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
