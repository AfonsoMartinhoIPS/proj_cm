import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nutri_scan/core/core.dart';

/// Um widget que renderiza um fundo animado com efeito de ondas utilizando um fragment shader.
///
/// O ciclo de vida do relógio ([Ticker]) está sincronizado com o carregamento assíncrono
/// do ficheiro `.frag` para evitar atualizações desnecessárias de frame (rebuilts)
/// antes de o shader estar pronto para desenhar.
///
/// Exemplo de uso:
/// ```dart
/// WaveBackground(
///   shaderPath: 'shaders/custom_wave.frag',
///   child: Text('Conteúdo sobreposto'),
/// )
/// ```
class WaveBackground extends StatefulWidget {
  /// O widget que será renderizado por cima do fundo animado.
  final Widget? child;

  /// O caminho do asset que aponta para o ficheiro compilado do fragment shader GLSL.
  ///
  /// Por defeito usa 'shaders/wave.frag'. Certifica que está devidamente
  /// declarado no ficheiro pubspec.yaml.
  final String shaderPath;

  /// Cria um [WaveBackground].
  ///
  /// Por defeito utiliza o shader em `shaders/wave.frag`. Podes fornecer um
  /// [child] que será desenhado por cima das ondas.
  const WaveBackground({
    super.key,
    this.child,
    this.shaderPath = 'shaders/wave.frag',
  });

  @override
  State createState() => _WaveBackgroundState();
}

/// Estado do [WaveBackground] que gere o carregamento do shader e a animação.
class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = elapsed.inMilliseconds / 1000.0;
        });
      }
    });
    _loadShader();
  }

  /// Carrega o [FragmentProgram] de forma assíncrona a partir dos assets.
  ///
  /// Se o carregamento for bem-sucedido, inicializa o relógio da animação.
  /// Em caso de falha (ex: ficheiro em falta ou corrompido), regista o erro no [logger]
  /// e ativa o estado de fallback.
  Future _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(widget.shaderPath);
      if (!mounted) return;
      setState(() {
        _shader = program.fragmentShader();
      });
      _ticker.start();
    } catch (e) {
      logger.e('WaveBackground: Erro ao carregar o shader: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_hasError || _shader == null) {
      return Container(
        color: colorScheme.surface,
        child: widget.child,
      );
    }

    final bg = colorScheme.surface;
    final wave = colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _WavePainter(
            shader: _shader!,
            time: _elapsedSeconds,
            backgroundColor: bg,
            waveColor: wave,
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// O [CustomPainter] responsável por alimentar e desenhar o fragment shader na tela.
class _WavePainter extends CustomPainter {
  /// O shader instanciado pronto para execução na GPU.
  final ui.FragmentShader shader;

  /// O tempo total decorrido em segundos desde o início da animação.
  final double time;

  /// Cor de fundo que o shader usará como base.
  final Color backgroundColor;

  /// Cor das ondas que o shader desenhará.
  final Color waveColor;

  /// Cria um [_WavePainter].
  ///
  /// Todos os parâmetros são obrigatórios.
  _WavePainter({
    required this.shader,
    required this.time,
    required this.backgroundColor,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, backgroundColor.r)
      ..setFloat(4, backgroundColor.g)
      ..setFloat(5, backgroundColor.b)
      ..setFloat(6, waveColor.r)
      ..setFloat(7, waveColor.g)
      ..setFloat(8, waveColor.b);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.waveColor != waveColor;
  }
}