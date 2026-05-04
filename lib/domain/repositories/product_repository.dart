import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/entities/saved_product.dart';

abstract class ProductRepository {
  Future<Product?> getByBarcode(String barcode);
  Future<void> save(Product product);

  Future<List<SavedProduct>> getSavedProducts(String uid);
  Future<SavedProduct?> getSavedProduct(String uid, String barcode);
  Future<void> saveForUser(String uid, SavedProduct savedProduct);
  Future<void> updateNotes(String uid, String barcode, String? notes);
  Future<void> deleteSaved(String uid, String barcode);
}
