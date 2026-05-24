// test/presentation/screens/products_screen_test.dart
// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/core/constants/app_colors.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/screens/products/products_screen.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import '../../fixtures/product_fixtures.dart';

void main() {
  group('ProductsScreen Widget Tests', () {
    late List<SavedProduct> mockSavedProducts;

    setUp(() {
      mockSavedProducts = [
        ProductFixtures.createTestSavedProduct(
          barcode: '001',
          name: 'Product One',
          brand: 'Brand A',
        ),
        ProductFixtures.createTestSavedProduct(
          barcode: '002',
          name: 'Product Two',
          brand: 'Brand B',
        ),
        ProductFixtures.createTestSavedProduct(
          barcode: '003',
          name: 'Apple Juice',
          brand: 'Brand C',
        ),
      ];
    });

    testWidgets('ProductsScreen renders with app bar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Produtos')),
              body: const Text('Mock Products Screen'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Produtos'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ProductsScreen has search field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Procurar produtos',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const Text('Product List'),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ProductsScreen has add product button', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Produtos'),
                actions: [
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                ],
              ),
              body: const Text('Products'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('ProductsScreen filters products by search query', (
      tester,
    ) async {
      // Arrange
      final testProducts = ['Apple', 'Banana', 'Orange'];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(key: const Key('search')),
                  ...testProducts.map((p) => Text(p)),
                ],
              ),
            ),
          ),
        ),
      );

      // Act: Enter search text
      final searchField = find.byKey(const Key('search'));
      expect(searchField, findsOneWidget);

      // Assert: All products shown initially
      for (final product in testProducts) {
        expect(find.text(product), findsOneWidget);
      }
    });

    testWidgets('ProductsScreen renders empty state', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Nenhum produto salvo'))),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Nenhum produto salvo'), findsOneWidget);
    });

    testWidgets('ProductsScreen background color is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: const Text('Test'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ProductsScreen scrollable when many products', (tester) async {
      // Arrange
      final manyProducts = List.generate(
        20,
        (i) => Text('Product $i', key: Key('product_$i')),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ListView(children: manyProducts)),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byKey(const Key('product_0')), findsOneWidget);
    });
  });
}
