import 'package:nutri_scan/domain/entities/feedback_entry.dart';

/// Interface de persistência para [FeedbackEntry].
///
/// Apenas suporta criação (`submit`) — o utilizador não lê nem edita
/// feedback existente. As mensagens são consumidas off-band pela equipa de
/// desenvolvimento via Firebase Console.
abstract class FeedbackRepository {
  /// Cria um novo documento de feedback no Firestore.
  ///
  /// Atira em caso de falha de rede / permissão para permitir que o ecrã
  /// surface o erro ao utilizador. Não devolve um id porque nenhum caller
  /// precisa.
  Future<void> submit(FeedbackEntry entry);
}
