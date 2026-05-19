import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';
import 'package:nutri_scan/presentation/widgets/nutri_button.dart';
import 'package:nutri_scan/main.dart';

void main() {
  group('Widgets Reutilizáveis - NutriScan', () {
    
    testWidgets('Deve exibir o label e o hint no NutriTextField', (WidgetTester tester) async {
      // 1. Constrói o widget dentro de um MaterialApp (necessário para o tema e localização)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutriTextField(
              label: 'Email',
              hint: 'teste@email.com',
            ),
          ),
        ),
      );

      // 2. Verifica se o label (em maiúsculas conforme o código) aparece
      expect(find.text('EMAIL'), findsOneWidget);
      
      // 3. Verifica se o hint text aparece
      expect(find.text('teste@email.com'), findsOneWidget);
    });

    testWidgets('Deve executar a função onPressed ao clicar no NutriButton', (WidgetTester tester) async {
      bool foiPressionado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutriButton(
              text: 'Entrar',
              onPressed: () => foiPressionado = true,
            ),
          ),
        ),
      );

      // Encontra o botão pelo texto e clica
      await tester.tap(find.text('Entrar'));
      
      // Reconstrói o widget após a interação
      await tester.pump();

      // Verifica se a variável mudou para true
      expect(foiPressionado, isTrue);
    });

    testWidgets('NutriButton deve exibir texto secundário quando fornecido', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutriButton(
              text: 'Já tenho conta',
              secondaryText: ' Entrar',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Já tenho conta'), findsOneWidget);
      expect(find.text(' Entrar'), findsOneWidget);
    });
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}