
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/repositories/product_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDatabase();
    await FirebaseAuth.instance.signInAnonymously();
  });

  testWidgets('Fetch product from OpenFoodAPI', (tester) async {
    ProductRepository productRepository = ProductRepositoryImpl();

    Product? product = await productRepository.getByBarcode('7892840816773');
    logger.d("Product fetched: ${product?.name}");

    expect(product, isNotNull);
  });
}
