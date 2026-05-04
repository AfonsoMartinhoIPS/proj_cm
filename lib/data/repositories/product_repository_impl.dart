import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/core/database/firestore_paths.dart';
import 'package:projeto/core/utils/logger.dart';
import 'package:projeto/data/datasiources/open_food_facts_datasource.dart';
import 'package:projeto/data/models/product_model.dart';
import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/repositories/product_repository.dart';

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
}
