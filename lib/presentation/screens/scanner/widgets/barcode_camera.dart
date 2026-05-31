import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Câmara ao vivo que faz a leitura de códigos de barras.
///
/// Utiliza o [MobileScanner] para detetar formatos EAN/UPC/QR e comunica
/// o código lido através do callback [onBarcode]. Apenas o primeiro código
/// detetado é reportado; depois disso a câmara é parada para evitar leituras
/// múltiplas do mesmo código.
///
/// Exibe um visor com cantos decorativos e uma linha central para guiar o
/// utilizador, mas a deteção funciona em toda a área da câmara.
class BarcodeCamera extends StatefulWidget {
  /// Callback invocado quando um código de barras válido é detetado.
  ///
  /// Recebe a string do código (ex.: "5601234567890").
  final ValueChanged<String> onBarcode;

  /// Cria um [BarcodeCamera].
  ///
  /// O parâmetro [onBarcode] é obrigatório.
  const BarcodeCamera({super.key, required this.onBarcode});

  @override
  State<BarcodeCamera> createState() => _BarcodeCameraState();
}

/// Estado do [BarcodeCamera] que gere o ciclo de vida do [MobileScannerController].
class _BarcodeCameraState extends State<BarcodeCamera> {
  late final MobileScannerController _controller;
  bool _handled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
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

  /// Processa uma captura de código de barras.
  ///
  /// Extrai o primeiro valor válido e, se ainda não tiver sido tratado,
  /// chama [onBarcode] e para o controlador da câmara.
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
                  child: NutriFeedback.error(
                    message: 'Câmara indisponível: $_error',
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

/// Sobreposição decorativa com cantos em forma de L e uma linha central.
///
/// Serve apenas como guia visual para o utilizador; a deteção do código
/// de barras funciona em toda a área da câmara, independentemente do visor.
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

  /// Constrói um canto do visor.
  ///
  /// Desenha uma linha horizontal e/ou vertical com a cor secundária,
  /// dependendo dos parâmetros [isTop] e [isLeft].
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