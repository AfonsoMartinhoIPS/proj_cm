// lib/presentation/widgets/wave_background.dart
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
///  ```
///
class WaveBackground extends StatefulWidget {
  /// O widget que será renderizado por cima do fundo animado.
  final Widget? child;

  /// O caminho do asset que aponta para o ficheiro compilado do fragment shader GLSL.
  ///
  /// Por defeito usa 'shaders/wave.frag'. Certifica que está devidamente
  /// declarado no ficheiro pubspec.yaml.
  final String shaderPath;

  const WaveBackground({
    super.key,
    this.child,
    this.shaderPath = 'shaders/wave.frag',
  });

  @override
  State createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground> with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // 1. Apenas configuramos o Ticker, NÃO o iniciamos aqui.
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = elapsed.inMilliseconds / 1000.0;
        });
      }
    });

    // 2. Dispara o carregamento assíncrono
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

      // 3. O Shader já existe? Então agora sim, podemos iniciar o relógio com segurança.
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
    // Evita fugas de memória parando o ticker se ele estiver ativo
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se ainda está a carregar e não deu erro, pode mostrar o fundo básico
    // enquanto o shader compila em background (geralmente leva menos de 100ms)
    if (_hasError || _shader == null) {
      return Container(color: AppColors.background, child: widget.child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _WavePainter(shader: _shader!, time: _elapsedSeconds),
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

  _WavePainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Apenas 3 floats a serem enviados (Width, Height, Time)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    // Evita repintar se o valor do tempo for idêntico ao do frame anterior.
    return oldDelegate.time != time;
  }
}
