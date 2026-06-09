// lib/core/utils/date_key.dart

/// Converte um [DateTime] numa chave de documento no formato `YYYY-MM-DD`.
///
/// Esta chave é utilizada como identificador único para os documentos diários
/// de nutrição em `nutrition_logs/{date}` no Firestore.
///
/// Exemplo: `dateKey(DateTime(2025, 5, 1))` → `"2025-05-01"`.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Obtém a chave de documento correspondente à data atual.
///
/// Equivalente a `dateKey(DateTime.now())`.
String todayKey() => dateKey(DateTime.now());