import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  void _openManualEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets the sheet resize for the keyboard
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ManualBarcodeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Spacer(),
                Text('Scan Barcode',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 16, fontWeight: FontWeight.bold)),
                Spacer(),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: AppColors.border, size: 40),
                  _buildScannerOverlay(),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Aponta a câmara para o código de barras do produto',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton(
              onPressed: () => _openManualEntry(context),
              child: const Text('Inserir código manualmente', style: TextStyle(fontSize: 14)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          _corner(top: 0, left: 0, isTop: true, isLeft: true),
          _corner(top: 0, right: 0, isTop: true, isLeft: false),
          _corner(bottom: 0, left: 0, isTop: false, isLeft: true),
          _corner(bottom: 0, right: 0, isTop: false, isLeft: false),
          Center(
            child: Container(
              width: 180,
              height: 2,
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top:    isTop    ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            bottom: !isTop   ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            left:   isLeft   ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            right:  !isLeft  ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for entering a barcode by hand. Owns its controller so it
/// is created/disposed with the sheet's lifecycle.
class _ManualBarcodeSheet extends StatefulWidget {
  const _ManualBarcodeSheet();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduz um código de barras')),
      );
      return;
    }
    Navigator.of(context).pop();             // close sheet first
    context.push('/products/$barcode');      // open details screen
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
          const Text(
            'Inserir código de barras',
            style: TextStyle(color: AppColors.onBackground, fontSize: 16, fontWeight: FontWeight.bold),
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
            child: const Text('Buscar produto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
