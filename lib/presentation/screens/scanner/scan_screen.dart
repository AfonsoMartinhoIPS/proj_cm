import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/screens/scanner/widgets/barcode_camera.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de scanner de código de barras com dois modos de funcionamento.
///
/// 1. **Modo separador** (padrão, `returnBarcode: false`) — aberto a partir da
///    navegação inferior. Ao detetar ou inserir um código, navega para
///    `/products/$barcode`.
///
/// 2. **Modo de seleção** (`returnBarcode: true`) — usado por fluxos que
///    precisam de um código de barras como resultado (ex.: `ProductPicker`).
///    Ao detetar ou inserir um código, fecha a rota devolvendo o código como
///    resultado (`context.pop(barcode)`).
///
/// Ambos os modos partilham a mesma interface: a câmara ao vivo do
/// [BarcodeCamera] e o botão para entrada manual.
class ScanScreen extends StatelessWidget {
  /// Quando `true`, o scanner termina devolvendo o código de barras.
  ///
  /// Quando `false` (padrão), o scanner navega para os detalhes do produto.
  final bool returnBarcode;

  /// Cria um [ScanScreen].
  ///
  /// O parâmetro [returnBarcode] controla o comportamento após a leitura.
  const ScanScreen({super.key, this.returnBarcode = false});

  /// Trata o código de barras recebido, seja da câmara ou da folha manual.
  ///
  /// No modo de seleção, fecha o ecrã com o código; caso contrário, navega
  /// para a página de detalhes do produto.
  void _handleBarcode(BuildContext context, String barcode) {
    logger.d(
      'ScanScreen: handle barcode=$barcode (returnBarcode=$returnBarcode)',
    );
    if (returnBarcode) {
      context.pop(barcode);
    } else {
      context.push('/products/$barcode');
    }
  }

  /// Abre a folha inferior para inserção manual de um código de barras.
  void _openManualEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ManualBarcodeSheet(
        onBarcode: (code) => _handleBarcode(context, code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: NutriTopNavBar(
        showBackButton: returnBarcode,
        title: 'Scan Barcode',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: BarcodeCamera(
                onBarcode: (code) => _handleBarcode(context, code),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: NutriLabel(
                'Aponta a câmara para o código de barras do produto',
                textAlign: TextAlign.center,
                color: colorScheme.onSurfaceVariant,
                variant: NutriLabelVariant.body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: NutriButton.transparent(
                label: 'Inserir código manualmente',
                onPressed: () => _openManualEntry(context),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Folha inferior para inserção manual de um código de barras.
///
/// Contém um campo de texto para o código e um botão para submeter a pesquisa.
/// A decisão de navegação é delegada ao ecrã principal através de [onBarcode].
class _ManualBarcodeSheet extends StatefulWidget {
  /// Callback invocado quando o utilizador submete um código de barras válido.
  final ValueChanged<String> onBarcode;

  /// Cria uma [_ManualBarcodeSheet].
  ///
  /// O parâmetro [onBarcode] é obrigatório.
  const _ManualBarcodeSheet({required this.onBarcode});

  @override
  State<_ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

/// Estado da [_ManualBarcodeSheet] que gere o campo de texto e a submissão.
class _ManualBarcodeSheetState extends State<_ManualBarcodeSheet> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  /// Valida e submete o código de barras introduzido.
  ///
  /// Se o campo estiver vazio, exibe uma mensagem de erro.
  /// Caso contrário, fecha a folha e invoca [onBarcode].
  void _submit() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      NutriFeedback.showError(context, 'Introduz um código de barras');
      return;
    }
    Navigator.of(context).pop();
    widget.onBarcode(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NutriLabel(
            'Inserir código de barras',
            color: colorScheme.onSurface,
            variant: NutriLabelVariant.body,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          NutriTextField(
            controller: _barcodeController,
            label: 'Código de barras',
            hint: 'Ex. 5601234567890',
            icon: Icons.qr_code_2,
            keyboardType: TextInputType.number,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          NutriButton(label: 'Procurar produto', onPressed: _submit),
        ],
      ),
    );
  }
}