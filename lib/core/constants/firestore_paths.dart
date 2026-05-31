/// Caminhos normalizados para documentos e coleções do Firestore.
///
/// Centraliza a construção de referências para evitar duplicação de strings
/// e facilitar alterações futuras na estrutura da base de dados.
class FirestorePaths {
  /// Caminho para o documento de um produto (`products/{barcode}`).
  static String product(String barcode) => 'products/$barcode';

  /// Caminho para o documento de um utilizador (`users/{uid}`).
  static String user(String uid) => 'users/$uid';

  /// Caminho para a coleção de produtos guardados de um utilizador
  /// (`users/{uid}/saved_products`).
  static String savedProducts(String uid) => 'users/$uid/saved_products';

  /// Caminho para o documento de um produto guardado específico
  /// (`users/{uid}/saved_products/{barcode}`).
  static String savedProduct(String uid, String barcode) =>
      'users/$uid/saved_products/$barcode';

  /// Caminho para o documento de registo nutricional de um dia
  /// (`users/{uid}/nutrition_logs/{date}`).
  static String nutritionLog(String uid, String date) =>
      'users/$uid/nutrition_logs/$date';

  /// Caminho para a coleção de registos nutricionais de um utilizador
  /// (`users/{uid}/nutrition_logs`).
  static String nutritionLogs(String uid) => 'users/$uid/nutrition_logs';
}