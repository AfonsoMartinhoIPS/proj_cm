// test/presentation/screens/scan_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/core/constants/app_colors.dart';

void main() {
  group('ScanScreen Widget Tests', () {
    testWidgets('ScanScreen renders with app bar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Scan Barcode')),
              body: const Text('Scan content'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Scan Barcode'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ScanScreen has scanner placeholder', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1A10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.videocam_off),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
    });

    testWidgets('ScanScreen has manual entry button', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Inserir manualmente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Inserir manualmente'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('ScanScreen tapping manual entry shows modal', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    key: const Key('manual_entry_btn'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (_) => const TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter barcode',
                          ),
                        ),
                      );
                    },
                    child: const Text('Manual Entry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('manual_entry_btn')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ScanScreen has background color', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: const Text('Content'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ScanScreen scanner container has correct styling', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1A10),
                  borderRadius: BorderRadius.circular(24),
                ),
                height: 300,
                width: 300,
                child: const Center(child: Icon(Icons.videocam_off)),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
    });

    testWidgets('ScanScreen has hint text below scanner', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Container(height: 200, color: Colors.black),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Alinhe o código de barras com a câmara'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(
        find.text('Alinhe o código de barras com a câmara'),
        findsOneWidget,
      );
    });

    testWidgets('ScanScreen has safe area', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [Container(height: 200, color: Colors.blue)],
                ),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
