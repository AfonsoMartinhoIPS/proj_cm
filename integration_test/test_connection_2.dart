import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/repositories/product_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDatabase();
    await FirebaseAuth.instance.signInAnonymously();
  });

  testWidgets('save and fetch product from Firestore', (tester) async {
    ProductRepository repo = ProductRepositoryImpl();

    Product product = Product(
      barcode: '1234567890123',
      name: 'Test Product',
      brand: 'Test Brand',
      displayQuantity: '500g',
      nutriments: Nutriments(
        caloriesPer100g: 200,
        carbsPer100g: 30,
        fatPer100g: 10,
        proteinPer100g: 5,
      ),
      source: 'test',
      fetchedAt: DateTime.now(),
    );

    await repo.save(product);
    final saved = await repo.getByBarcode(product.barcode);

    expect(saved, isNotNull);
    expect(saved!.name, 'Test Product');
    expect(saved.nutriments.caloriesPer100g, 200);
  });
}
