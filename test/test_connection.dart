import 'package:flutter_test/flutter_test.dart';
import 'package:projeto/core/database/database.dart';
import 'package:projeto/data/repositories/product_repository_impl.dart';
import 'package:projeto/domain/entities/nutriments.dart';
import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/repositories/product_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDatabase();
  });

  test('save and fetch product from Firestore', () async {
    ProductRepository repo = ProductRepositoryImpl();

    const product = Product(
      barcode: '1234567890123',
      name: 'Test Product',
      brand: 'Test Brand',
      displayQuantity: '500g',
      imageUrl: 'https://example.com/image.jpg',
      imageThumbnailUrl: 'https://example.com/thumb.jpg',
      ingredientsText: 'Water, Sugar, Flavor',
      allergenTags: ['en:milk', 'en:nuts'],
      tracesTags: ['en:gluten'],
      labelTags: ['en:organic'],
      nutriscoreGrade: 'a',
      novaGroup: 1,
      nutriments: Nutriments(
        caloriesPer100g: 200,
        carbsPer100g: 30,
        sugarsPer100g: 20,
        fatPer100g: 10,
        saturatedFatPer100g: 5,
        proteinPer100g: 5,
        saltPer100g: 0.5,
        fiberPer100g: 2,
      ),
      source: 'test',
    );

    await repo.save(product);
    final saved = await repo.getByBarcode(product.barcode);

    expect(saved, isNotNull);
    expect(saved!.name, 'Test Product');
    expect(saved.nutriments.caloriesPer100g, 200);

    print('✓ product saved and fetched: ${saved.name}');
  });
}
