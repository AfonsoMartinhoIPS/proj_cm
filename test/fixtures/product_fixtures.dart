// test/fixtures/product_fixtures.dart
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

/// Factory for creating test Product entities
class ProductFixtures {
  static Product createTestProduct({
    String barcode = '8710398038274',
    String name = 'Test Product',
    String? brand = 'Test Brand',
    Nutriments? nutriments,
    DateTime? fetchedAt,
    String source = 'openfoodfacts',
  }) {
    return Product(
      barcode: barcode,
      name: name,
      brand: brand,
      displayQuantity: '100g',
      imageUrl: 'https://example.com/image.jpg',
      imageThumbnailUrl: 'https://example.com/thumb.jpg',
      ingredientsText: 'Water, Sugar, Salt',
      allergenTags: const ['gluten', 'dairy'],
      tracesTags: const [],
      labelTags: const ['organic', 'vegan'],
      nutriscoreGrade: 'A',
      novaGroup: 1,
      nutriments: nutriments ?? _defaultNutriments(),
      source: source,
      fetchedAt: fetchedAt ?? DateTime.now(),
    );
  }

  static Nutriments _defaultNutriments() {
    return const Nutriments(
      caloriesPer100g: 250,
      carbsPer100g: 50,
      sugarsPer100g: 15,
      fatPer100g: 8,
      saturatedFatPer100g: 2,
      proteinPer100g: 5,
      saltPer100g: 1,
      fiberPer100g: 3,
    );
  }

  static SavedProduct createTestSavedProduct({
    String barcode = '8710398038274',
    String name = 'Saved Product',
    String? brand = 'Test Brand',
    DateTime? savedAt,
    List<SavedProductNote> notes = const [],
  }) {
    return SavedProduct(
      barcode: barcode,
      savedAt: savedAt ?? DateTime.now(),
      name: name,
      brand: brand,
      imageUrl: 'https://example.com/image.jpg',
      caloriesPer100g: 250,
      notes: notes,
    );
  }
}
