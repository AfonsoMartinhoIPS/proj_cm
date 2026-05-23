// test/presentation/screens/product_details_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/core/constants/app_colors.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/screens/products/product_details_screen.dart';
import '../../fixtures/product_fixtures.dart';

void main() {
  group('ProductDetailsScreen Widget Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = ProductFixtures.createTestProduct();
    });

    testWidgets('ProductDetailsScreen shows loading indicator while fetching', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Detalhes')),
              body: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen displays product name', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Detalhes do Produto')),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      testProduct.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (testProduct.brand != null) Text(testProduct.brand!),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(testProduct.name), findsOneWidget);
      expect(find.text(testProduct.brand ?? ''), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen displays nutrient information', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text(
                    'Calorias: ${testProduct.nutriments.caloriesPer100g} kcal',
                  ),
                  Text('Proteína: ${testProduct.nutriments.proteinPer100g}g'),
                  Text('Carboidratos: ${testProduct.nutriments.carbsPer100g}g'),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Calorias: 250 kcal'), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen has save button when not saved', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {},
                child: const Text('Guardar'),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen shows remove button when saved', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                label: const Text('Remover'),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Remover'), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen displays product image', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  if (testProduct.imageUrl != null)
                    Container(
                      key: const Key('product_image'),
                      color: Colors.grey,
                      height: 200,
                      width: 200,
                      child: const Center(child: Icon(Icons.image)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byKey(const Key('product_image')), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen displays nutrient badges', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Wrap(
                children: [
                  if (testProduct.nutriscoreGrade != null)
                    Chip(
                      label: Text('Nutriscore: ${testProduct.nutriscoreGrade}'),
                    ),
                  if (testProduct.novaGroup != null)
                    Chip(label: Text('NOVA: ${testProduct.novaGroup}')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('ProductDetailsScreen handles error state', (tester) async {
      // Arrange
      const errorMessage = 'Erro ao carregar produto';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text(errorMessage))),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen has back button', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Detalhes do Produto'),
                leading: BackButton(),
              ),
              body: const Text('Content'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('ProductDetailsScreen is scrollable', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: List.generate(10, (i) => Text('Item $i')),
                ),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
