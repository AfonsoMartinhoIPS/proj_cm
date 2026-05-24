import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/datasources/open_food_facts_datasource.dart';
import 'package:nutri_scan/data/models/product_model.dart';
import 'package:nutri_scan/data/models/saved_product_model.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final _db = FirebaseFirestore.instance;

  bool _isStale(Product product) {
    if (product.fetchedAt == null) return true;
    return DateTime.now().difference(product.fetchedAt!).inDays >= 15;
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    logger.d('getByBarcode: $barcode — checking Firestore');
    final doc = await _db.doc(FirestorePaths.product(barcode)).get();
    final cached = ProductModel.fromDoc(doc);

    if (cached != null && !_isStale(cached)) {
      logger.d('cache hit: ${cached.name}');
      return cached;
    }

    logger.d('cache miss — fetching from OpenFoodFacts');
    final product = await OpenFoodFactsDatasource.getByBarcode(barcode);
    if (product != null) {
      logger.d('fetched: ${product.name} — saving to Firestore');
      await save(product);
    }

    return product;
  }

  @override
  Future<void> save(Product product) async {
    await _db
        .doc(FirestorePaths.product(product.barcode))
        .set(ProductModel.toMap(product), SetOptions(merge: true));
  }

  @override
  Future<List<SavedProduct>> getSavedProducts(String uid, int count) async {
    final snapshot = await _db
        .collection(FirestorePaths.savedProducts(uid))
        .orderBy('savedAt', descending: true)
        .limit(count)
        .get();
    return snapshot.docs
        .map((doc) => SavedProductModel.fromDoc(doc))
        .whereType<SavedProduct>()
        .toList();
  }

  @override
  Future<SavedProduct?> getSavedProduct(String uid, String barcode) async {
    final doc = await _db.doc(FirestorePaths.savedProduct(uid, barcode)).get();
    return SavedProductModel.fromDoc(doc);
  }

  @override
  Future<void> saveForUser(String uid, SavedProduct savedProduct) async {
    await _db
        .doc(FirestorePaths.savedProduct(uid, savedProduct.barcode))
        .set(SavedProductModel.toMap(savedProduct), SetOptions(merge: true));
  }

  @override
  Future<void> setNotes(String uid, String barcode, List<SavedProductNote> notes) async {
    await _db.doc(FirestorePaths.savedProduct(uid, barcode)).update({
      'notes': notes
          .map((note) => {
                'text': note.text,
                'createdAt': Timestamp.fromDate(note.createdAt),
              })
          .toList(),
    });
  }

  @override
  Future<void> deleteSaved(String uid, String barcode) async {
    await _db.doc(FirestorePaths.savedProduct(uid, barcode)).delete();
  }
}
