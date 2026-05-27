import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Live-camera barcode scanner with a corner-bracket viewfinder overlay.
///
/// Owns the [MobileScannerController] lifecycle (start in `initState`, stop
/// in `dispose`). Reports the decoded barcode string up via [onBarcode]; the
/// parent decides what to do with it (route, pop, etc.).
///
/// **Debounce** - `MobileScanner.onDetect` fires multiple times per second
/// while the same code stays in frame. We forward exactly one callback per
/// scanner session and then stop the controller; the parent typically
/// navigates away, but if it doesn't, [resume] can be called to re-arm.
class BarcodeCamera extends StatefulWidget {
  final ValueChanged<String> onBarcode;

  const BarcodeCamera({super.key, required this.onBarcode});

  @override
  State<BarcodeCamera> createState() => _BarcodeCameraState();
}

class _BarcodeCameraState extends State<BarcodeCamera> {
  late final MobileScannerController _controller;
  bool _handled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      // EAN/UPC for product barcodes + QR for the occasional QR-encoded SKU.
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.qrCode,
      ],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;
    setState(() => _handled = true);
    _controller.stop();
    logger.d('BarcodeCamera: detected $raw');
    widget.onBarcode(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              _error = error.errorDetails?.message ?? error.errorCode.name;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: NutriLabel(
                    'Câmara indisponível: $_error',
                    textAlign: TextAlign.center,
                    variant: NutriLabelVariant.small,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
          _ViewfinderOverlay(),
        ],
      ),
    );
  }
}

/// Corner-bracket viewfinder. Purely decorative - the scanner reads anywhere
/// in the camera frame, the brackets just guide the user.
class _ViewfinderOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

  Widget _corner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.secondary, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: AppColors.secondary, width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: AppColors.secondary, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: AppColors.secondary, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
