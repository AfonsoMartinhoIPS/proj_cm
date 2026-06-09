// test/domain/entities/product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';

void main() {
  group('Product Entity Tests', () {
    late Product product;
    late Nutriments nutriments;

    setUp(() {
      nutriments = const Nutriments(
        caloriesPer100g: 100,
        carbsPer100g: 20,
        sugarsPer100g: 5,
        fatPer100g: 5,
        saturatedFatPer100g: 1,
        proteinPer100g: 10,
        saltPer100g: 1.5,
        fiberPer100g: 2,
      );

      product = Product(
        barcode: '8710398038274',
        name: 'Test Product',
        brand: 'Test Brand',
        displayQuantity: '100g',
        imageUrl: 'https://example.com/image.jpg',
        imageThumbnailUrl: 'https://example.com/thumb.jpg',
        ingredientsText: 'Water, Sugar, Salt',
        allergenTags: const ['gluten', 'dairy'],
        tracesTags: const ['nuts'],
        labelTags: const ['organic'],
        nutriscoreGrade: 'A',
        novaGroup: 1,
        nutriments: nutriments,
        source: 'openfoodfacts',
        fetchedAt: DateTime(2024, 1, 15),
      );
    });

    test('Product should be created with correct values', () {
      expect(product.barcode, '8710398038274');
      expect(product.name, 'Test Product');
      expect(product.brand, 'Test Brand');
      expect(product.source, 'openfoodfacts');
      expect(product.allergenTags, contains('gluten'));
    });

    test('Product with different barcode should not be equal', () {
      final differentProduct = Product(
        barcode: '9999999999999',
        name: 'Test Product',
        brand: 'Test Brand',
        nutriments: nutriments,
        source: 'openfoodfacts',
        fetchedAt: DateTime(2024, 1, 15),
      );

      expect(product, isNot(differentProduct));
    });

    test('Product displayQuantity defaults to null', () {
      final minimalProduct = Product(
        barcode: '123',
        name: 'Minimal',
        nutriments: nutriments,
        source: 'manual',
        fetchedAt: DateTime.now(),
      );

      expect(minimalProduct.displayQuantity, isNull);
    });

    test('Product lists default to empty', () {
      final minimalProduct = Product(
        barcode: '123',
        name: 'Minimal',
        nutriments: nutriments,
        source: 'manual',
        fetchedAt: DateTime.now(),
      );

      expect(minimalProduct.allergenTags, isEmpty);
      expect(minimalProduct.tracesTags, isEmpty);
      expect(minimalProduct.labelTags, isEmpty);
    });
  });
}
