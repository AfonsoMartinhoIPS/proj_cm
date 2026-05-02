import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/core/database/firestore_paths.dart';
import 'package:projeto/data/models/product_model.dart';
import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<Product?> getByBarcode(String barcode) async {
    final doc = await _db.doc(FirestorePaths.product(barcode)).get();
    if (!doc.exists) return null;
    return ProductModel.fromDoc(doc);
  }

  @override
  Future<void> save(Product product) async {
    await _db
        .doc(FirestorePaths.product(product.barcode))
        .set(ProductModel.toMap(product), SetOptions(merge: true));
  }
}
