
class FirestorePaths {
  static String product(String barcode) => 'products/$barcode';
  static String user(String uid) => 'users/$uid';
  static String savedProducts(String uid) => 'users/$uid/saved_products';
  static String savedProduct(String uid, String barcode) => 'users/$uid/saved_products/$barcode';
  static String nutritionLog(String uid, String date) => 'users/$uid/nutrition_logs/$date';
  static String nutritionLogs(String uid) => 'users/$uid/nutrition_logs';
}