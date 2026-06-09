import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:permission_handler/permission_handler.dart';

/// Live-camera barcode scanner with a corner-bracket viewfinder overlay.
///
/// Owns the [MobileScannerController] lifecycle (start in `initState`, stop
/// in `dispose`). Reports the decoded barcode string up via [onBarcode]; the
/// parent decides what to do with it (route, pop, etc.).
///
/// **Debounce** - `MobileScanner.onDetect` fires multiple times per second
/// while the same code stays in frame. We forward exactly one callback per
/// scanner session and then stop the controller; the parent typically
/// navigates away, but if it doesn't, `_setActive(true)` re-arms it.
///
/// **Off-screen / background** - subscribes to [routeObserver] and
/// [WidgetsBindingObserver] so the camera is fully stopped when another
/// route is pushed above or the app is paused, and restarted when it returns
/// to the foreground. Saves battery and frees the sensor for other apps.
///
/// **Error fallback** - when `MobileScanner.errorBuilder` fires (camera
/// missing, permission denied, unsupported, etc.) the widget swaps the
/// preview for [_CameraFallback], which offers either "Tentar novamente" or
/// "Abrir Definições" depending on whether the permission was permanently
/// denied.
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

enum _CameraStatus { initializing, ready, error }

class _BarcodeCameraState extends State<BarcodeCamera>
    with RouteAware, WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _handled = false;
  _CameraStatus _status = _CameraStatus.initializing;
  MobileScannerException? _lastError;
  bool _permanentlyDenied = false;

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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscrever em didChangeDependencies (não initState) porque ModalRoute.of
    // requer um widget herdado que não está pronto em initState.
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// Turns the camera on/off and re-arms the handled flag so the next scan
  /// after `_setActive(true)` fires `onBarcode` again. Errors thrown by
  /// `start()` surface via [errorBuilder] which calls [_reportError].
  Future<void> _setActive(bool active) async {
    if (!mounted) return;
    if (active) {
      setState(() {
        _handled = false;
        _status = _CameraStatus.initializing;
        _lastError = null;
      });
      try {
        await _controller.start();
        if (mounted) setState(() => _status = _CameraStatus.ready);
      } catch (_) {
        // errorBuilder will fire and call _reportError.
      }
    } else {
      await _controller.stop();
    }
  }

  /// Called from `errorBuilder` (which runs during build, so we must defer
  /// setState). Also checks `permission_handler` to distinguish a one-off
  /// deny from a "Don't ask again" deny so the fallback can show the right
  /// action.
  void _reportError(MobileScannerException error) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final permDenied =
          error.errorCode == MobileScannerErrorCode.permissionDenied;
      final permanently = permDenied
          ? await Permission.camera.isPermanentlyDenied
          : false;
      if (!mounted) return;
      setState(() {
        _status = _CameraStatus.error;
        _lastError = error;
        _permanentlyDenied = permanently;
      });
    });
  }

  /// Retry handler from the fallback widget. If the user permanently denied
  /// camera access, the only fix is the OS Settings app; otherwise re-issue
  /// `start()` and hope they hit "Allow" this time.
  Future<void> _retry() async {
    if (_permanentlyDenied) {
      await openAppSettings();
      // Re-check on the next lifecycle resume — didChangeAppLifecycleState
      // will fire when the user returns from Settings.
      return;
    }
    await _setActive(true);
  }

  // Route lifecycle: stop the camera when another screen is pushed over us
  // (e.g. /products/$barcode); restart when we become the top route again.
  @override
  void didPushNext() => _setActive(false);

  @override
  void didPopNext() => _setActive(true);

  // App lifecycle: stop the camera when the app is backgrounded or paused,
  // restart on resume. Saves battery + releases the sensor for other apps.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _setActive(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _setActive(false);
        break;
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: _status == _CameraStatus.error
          ? _CameraFallback(
              error: _lastError,
              permanentlyDenied: _permanentlyDenied,
              onRetry: _retry,
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    _reportError(error);
                    return const SizedBox.expand();
                  },
                ),
                _ViewfinderOverlay(color: colorScheme.secondary),
              ],
            ),
    );
  }
}

/// Renders when the camera can't start. Shows a localized message based on
/// the error code and a single primary action: "Abrir Definições" if the
/// permission is permanently denied (only the OS can grant it back), or
/// "Tentar novamente" for transient / first-time deny / hardware errors.
class _CameraFallback extends StatelessWidget {
  final MobileScannerException? error;
  final bool permanentlyDenied;
  final VoidCallback onRetry;

  const _CameraFallback({
    required this.error,
    required this.permanentlyDenied,
    required this.onRetry,
  });

  String get _message {
    final code = error?.errorCode;
    if (permanentlyDenied) {
      return 'Acesso à câmara recusado. Concede a permissão nas definições para continuar.';
    }
    return switch (code) {
      MobileScannerErrorCode.permissionDenied =>
        'Acesso à câmara recusado. Toca em tentar novamente para autorizar.',
      MobileScannerErrorCode.unsupported =>
        'Câmara não suportada neste dispositivo.',
      _ => 'Falha ao iniciar a câmara. Tenta de novo.',
    };
  }

  IconData get _icon {
    if (permanentlyDenied ||
        error?.errorCode == MobileScannerErrorCode.permissionDenied) {
      return Icons.lock_outline;
    }
    return Icons.videocam_off;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: colorScheme.onSurfaceVariant, size: 40),
            const SizedBox(height: 16),
            NutriLabel(
              _message,
              textAlign: TextAlign.center,
              variant: NutriLabelVariant.small,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: NutriButton(
                label: permanentlyDenied ? 'Abrir Definições' : 'Tentar novamente',
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Corner-bracket viewfinder. Purely decorative - the scanner reads anywhere
/// in the camera frame, the brackets just guide the user.
class _ViewfinderOverlay extends StatelessWidget {
  final Color color;

  const _ViewfinderOverlay({required this.color});

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
              color: color.withValues(alpha: 0.5),
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
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
