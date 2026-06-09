// lib/domain/entities/feedback_entry.dart

/// Mensagem de feedback ou reporte de problema submetida por um utilizador.
///
/// Captura a mensagem livre escrita pelo utilizador e o contexto do
/// dispositivo de origem (recolhido automaticamente via `device_info_plus`)
/// para ajudar a reproduzir bugs específicos de marca/modelo/OS.
///
/// Persistido na coleção `feedback/{auto-id}` do Firestore. O timestamp de
/// criação é atribuído pelo servidor — esta entidade não o transporta.
class FeedbackEntry {
  /// UID do utilizador autenticado que submeteu o feedback.
  final String uid;

  /// Email do utilizador autenticado, para permitir resposta direta.
  final String email;

  /// Família do sistema operativo (`Android` / `iOS` / `Other`).
  final String device;

  /// Versão do sistema operativo (`Android 13`, `iOS 17.2`, …).
  final String osVersion;

  /// Marca + modelo do aparelho (`Samsung Galaxy S22`, `iPhone 15`, …).
  /// Pode ficar vazio se a deteção via `device_info_plus` falhar.
  final String model;

  /// Texto livre escrito pelo utilizador. Validado como não-vazio antes da
  /// submissão.
  final String message;

  const FeedbackEntry({
    required this.uid,
    required this.email,
    required this.device,
    required this.osVersion,
    required this.model,
    required this.message,
  });
}
