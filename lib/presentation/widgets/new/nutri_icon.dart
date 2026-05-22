import 'package:flutter/material.dart';

class NutriIcon extends StatelessWidget {
  final double? size;
  final BoxFit? fit;
  final bool fill;

  const NutriIcon({
    super.key,
    this.size,
    this.fit,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFit = fit ?? (fill ? BoxFit.cover : BoxFit.contain);

    // Widget base encapsulado com clipping para nunca sair fora das bordas do pai
    Widget imageWidget(double? targetSize) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(inheritRadius(context)),
        child: Image.asset(
          'assets/icon/icon_fill.png',
          width: targetSize,
          height: targetSize,
          fit: effectiveFit,
        ),
      );
    }

    if (size != null) {
      return imageWidget(size);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasWidthConstraint = constraints.maxWidth.isFinite;
        final hasHeightConstraint = constraints.maxHeight.isFinite;

        double finalSize;

        if (!hasWidthConstraint && !hasHeightConstraint) {
          finalSize = 48.0; 
        } else if (!hasWidthConstraint) {
          finalSize = constraints.maxHeight;
        } else if (!hasHeightConstraint) {
          finalSize = constraints.maxWidth;
        } else {
          finalSize = constraints.maxWidth < constraints.maxHeight 
              ? constraints.maxWidth 
              : constraints.maxHeight;
        }
            
        final adaptiveSize = fill ? finalSize : finalSize * 0.6;

        return imageWidget(adaptiveSize);
      },
    );
  }

  // Função auxiliar para tentar herdar o raio do container se aplicável
  double inheritRadius(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      // Retorna um fallback seguro caso o clip precise de suavizar cantos arredondados
      return 12.0; 
    }
    return 0.0;
  }
}