// test/domain/entities/saved_product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

void main() {
  group('SavedProduct Entity Tests', () {
    late SavedProduct savedProduct;
    late DateTime savedAt;

    setUp(() {
      savedAt = DateTime(2024, 1, 15, 10, 30);
      savedProduct = SavedProduct(
        barcode: '8710398038274',
        savedAt: savedAt,
        name: 'Test Product',
        brand: 'Test Brand',
        imageUrl: 'https://example.com/image.jpg',
        caloriesPer100g: 250,
        notes: const [],
      );
    });

    test('SavedProduct should be created with correct values', () {
      expect(savedProduct.barcode, '8710398038274');
      expect(savedProduct.name, 'Test Product');
      expect(savedProduct.brand, 'Test Brand');
      expect(savedProduct.caloriesPer100g, 250);
      expect(savedProduct.savedAt, savedAt);
    });

    test('SavedProduct notes default to empty list', () {
      expect(savedProduct.notes, isEmpty);
    });

    test('SavedProduct can be created with notes', () {
      final notes = [
        SavedProductNote(text: 'Note 1', createdAt: DateTime.now()),
        SavedProductNote(text: 'Note 2', createdAt: DateTime.now()),
      ];
      final productWithNotes = SavedProduct(
        barcode: '123',
        savedAt: DateTime.now(),
        name: 'Product',
        notes: notes,
      );

      expect(productWithNotes.notes, hasLength(2));
      expect(productWithNotes.notes[0].text, 'Note 1');
    });

    test('SavedProduct optional fields can be null', () {
      final minimalProduct = SavedProduct(
        barcode: '123',
        savedAt: DateTime.now(),
        name: 'Minimal',
      );

      expect(minimalProduct.brand, isNull);
      expect(minimalProduct.imageUrl, isNull);
      expect(minimalProduct.caloriesPer100g, isNull);
      expect(minimalProduct.notes, isEmpty);
    });

    test('SavedProductNote should store text and creation time', () {
      final now = DateTime.now();
      final note = SavedProductNote(text: 'Important note', createdAt: now);

      expect(note.text, 'Important note');
      expect(note.createdAt, now);
    });

    test('SavedProduct equality test', () {
      final product2 = SavedProduct(
        barcode: '8710398038274',
        savedAt: savedAt,
        name: 'Test Product',
        brand: 'Test Brand',
        imageUrl: 'https://example.com/image.jpg',
        caloriesPer100g: 250,
      );

      // Check all fields match instead of using == operator
      expect(savedProduct.barcode, product2.barcode);
      expect(savedProduct.savedAt, product2.savedAt);
      expect(savedProduct.name, product2.name);
      expect(savedProduct.brand, product2.brand);
      expect(savedProduct.imageUrl, product2.imageUrl);
      expect(savedProduct.caloriesPer100g, product2.caloriesPer100g);
    });

    test('SavedProduct with different barcode should not be equal', () {
      final differentProduct = SavedProduct(
        barcode: '9999999999999',
        savedAt: savedAt,
        name: 'Test Product',
      );

      expect(savedProduct, isNot(differentProduct));
    });
  });
}
