import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

abstract class ProductRepository {
  Future<Product?> getByBarcode(String barcode);
  Future<void> save(Product product);

  Future<List<SavedProduct>> getSavedProducts(String uid, int count);
  Future<SavedProduct?> getSavedProduct(String uid, String barcode);
  Future<void> saveForUser(String uid, SavedProduct savedProduct);
  Future<void> setNotes(String uid, String barcode, List<SavedProductNote> notes);
  Future<void> deleteSaved(String uid, String barcode);
}
