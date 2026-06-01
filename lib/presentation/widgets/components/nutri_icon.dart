import 'package:flutter/material.dart';

/// Widget de ícone adaptável que renderiza o logótipo da aplicação.
///
/// O [NutriIcon] calcula automaticamente o seu tamanho com base nas restrições
/// do widget pai, a menos que um [size] explícito seja fornecido.
/// Suporta dois modos de dimensionamento: preenchimento total ([fill] = true)
/// ou ícone com padding interno ([fill] = false, padrão).
class NutriIcon extends StatelessWidget {
  /// Tamanho exato (largura e altura) do ícone.
  ///
  /// Se `null`, o widget adapta-se às dimensões do pai ou usa 48.0 como fallback.
  final double? size;

  /// Estratégia de inscrição da imagem na caixa do widget.
  ///
  /// Se `null`, o comportamento é determinado pela flag [fill]:
  /// - `fill == true` → [BoxFit.cover]
  /// - `fill == false` → [BoxFit.contain]
  final BoxFit? fit;

  /// Define a estratégia de dimensionamento e preenchimento.
  ///
  /// * Se `true`, o ícone expande-se para ocupar todo o espaço disponível.
  /// * Se `false` (padrão), o tamanho é reduzido para 60% do espaço disponível,
  ///   funcionando como um ícone com padding interno.
  final bool fill;

  /// Cria um [NutriIcon].
  ///
  /// Se [size] for fornecido, o ícone terá dimensões fixas.
  /// Caso contrário, adapta-se ao espaço disponível respeitando a flag [fill].
  const NutriIcon({
    super.key,
    this.size,
    this.fit,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFit = fit ?? (fill ? BoxFit.cover : BoxFit.contain);

    if (size != null) {
      return _buildImage(context, size, effectiveFit);
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
        return _buildImage(context, adaptiveSize, effectiveFit);
      },
    );
  }

  /// Constrói o widget de imagem com recorte arredondado.
  Widget _buildImage(
    BuildContext context,
    double? targetSize,
    BoxFit fitStrategy,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_inheritRadius(context)),
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: targetSize,
        height: targetSize,
        fit: fitStrategy,
      ),
    );
  }

  /// Obtém o raio de curvatura herdado do contexto de renderização.
  ///
  /// Retorna 12.0 se o objeto de renderização for uma [RenderBox]; caso contrário, 0.0.
  double _inheritRadius(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return 12.0;
    }
    return 0.0;
  }
}