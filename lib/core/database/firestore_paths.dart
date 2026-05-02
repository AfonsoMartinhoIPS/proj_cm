
class FirestorePaths {
  static String product(String barcode) => 'products/$barcode';
  static String user(String uid) => 'users/$uid';
  static String savedProduct(String uid, String barcode)
      => 'users/$uid/saved_products/$barcode';
}