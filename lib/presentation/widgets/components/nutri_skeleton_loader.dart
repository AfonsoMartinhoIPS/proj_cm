import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Placeholder animado com efeito de shimmer para carregamento.
///
/// Exibe um retângulo com um gradiente que se desloca horizontalmente,
/// indicando que o conteúdo está a ser carregado. O tamanho e o raio
/// dos cantos são personalizáveis.
class NutriSkeletonLoader extends StatefulWidget {
  /// Largura do placeholder.
  final double width;

  /// Altura do placeholder.
  final double height;

  /// Raio dos cantos do placeholder.
  ///
  /// Se não for especificado, utiliza [AppSizes.radiusSm].
  final BorderRadius? borderRadius;

  /// Cria um [NutriSkeletonLoader].
  ///
  /// Os parâmetros [width] e [height] são obrigatórios.
  const NutriSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<NutriSkeletonLoader> createState() => _SkeletonLoaderState();
}

/// Estado do [NutriSkeletonLoader] que gere a animação do shimmer.
class _SkeletonLoaderState extends State<NutriSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surface;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusSm),
        color: baseColor,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            stops: [
              _controller.value - 0.3,
              _controller.value,
              _controller.value + 0.3,
            ].map((e) => e.clamp(0, 1).toDouble()).toList(),
          ).createShader(bounds);
        },
        child: Container(
          color: baseColor,
        ),
      ),
    );
  }
}