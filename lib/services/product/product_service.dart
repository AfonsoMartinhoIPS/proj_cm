import 'package:projeto/core/core.dart';

class ProductService {
  final db = Database.db;


  Future<List<Product>> getProducts() async {
    final snapshot = await db.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

}