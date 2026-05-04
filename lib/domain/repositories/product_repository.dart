import 'package:projeto/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Product?> getByBarcode(String barcode);
  Future<void> save(Product product);
}
