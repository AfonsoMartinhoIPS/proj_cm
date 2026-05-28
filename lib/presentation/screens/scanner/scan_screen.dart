import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/screens/scanner/widgets/barcode_camera.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Barcode scanner screen with two usage modes:
///
/// 1. **Tab mode** (default, `returnBarcode: false`) - opened from the bottom
///    nav. On scan or manual entry, pushes `/products/$barcode` so the user
///    lands on the product detail screen.
///
/// 2. **Pick mode** (`returnBarcode: true`) - opened from flows that need a
///    barcode result (e.g. AddMealScreen's product picker). On scan or manual
///    entry, pops the route with the barcode string as the result, so the
///    caller can `await context.push<String>(...)` and use the returned value.
///
/// The split exists because `/scan` (tab) lives inside the `ShellRoute` -
/// pushing it from a screen outside the shell would mount a second `MainShell`
/// and trigger duplicate Hero key reservations. The pick variant is registered
/// at top level so it can be pushed safely from anywhere.
///
/// This screen is intentionally stateless. Both input sources ([BarcodeCamera]
/// and [_ManualBarcodeSheet]) own their own state and report up via a
/// `ValueChanged<String>` callback. The screen's only job is deciding what to
/// do with the resulting barcode (pop vs push).
class ScanScreen extends StatelessWidget {
  /// When `true`, scanner ends by popping the route with the barcode string.
  /// When `false`, scanner ends by pushing the product details route.
  final bool returnBarcode;

  const ScanScreen({super.key, this.returnBarcode = false});

  void _handleBarcode(BuildContext context, String barcode) {
    logger.d('ScanScreen: handle barcode=$barcode (returnBarcode=$returnBarcode)');
    if (returnBarcode) {
      context.pop(barcode);
    } else {
      context.push('/products/$barcode');
    }
  }

  void _openManualEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ManualBarcodeSheet(
        // Sheet pops itself, then we resolve via the same handler the camera
        // path uses. Single source of truth for "what happens with a barcode".
        onBarcode: (code) => _handleBarcode(context, code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: NutriLabel(
                'Aponta a câmara para o código de barras do produto',
                textAlign: TextAlign.center,
                color: AppColors.textMuted,
                variant: NutriLabelVariant.body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton(
                onPressed: () => _openManualEntry(context),
                child: const NutriLabel(
                  'Inserir código manualmente',
                  variant: NutriLabelVariant.body,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for entering a barcode by hand. Owns its [TextEditingController]
/// for the field lifecycle and nothing else - routing decisions live on the
/// parent screen via [onBarcode].
class _ManualBarcodeSheet extends StatefulWidget {
  final ValueChanged<String> onBarcode;

  const _ManualBarcodeSheet({required this.onBarcode});

  @override
  State<_ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

class _ManualBarcodeSheetState extends State<_ManualBarcodeSheet> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

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
    // Bottom padding picks up keyboard inset so the field stays visible.
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NutriLabel(
            'Inserir código de barras',
            color: AppColors.onBackground,
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
          ElevatedButton(
            onPressed: _submit,
            child: const NutriLabel(
              'Procurar produto',
              variant: NutriLabelVariant.body,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
