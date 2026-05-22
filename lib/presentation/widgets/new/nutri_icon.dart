// lib/presentation/widgets/nutri_icon.dart
import 'package:flutter/material.dart';

/// Um widget de ícone adaptável que renderiza o logótipo da aplicação (`icon_fill.png`).
///
/// O [NutriIcon] calcula automaticamente o seu tamanho com base nas restrições
/// ([BoxConstraints]) do widget pai, a menos que um [size] explícito seja fornecido.
/// Também herda dinamicamente um raio de curvatura para o recorte das bordas.
///
/// ### Exemplo de uso:
/// ```dart
/// // Tamanho fixo de 24x24
/// NutriIcon(size: 24.0)
///
/// // Adaptável ao pai, preenchendo todo o espaço disponível
/// NutriIcon(fill: true)
/// ```
class NutriIcon extends StatelessWidget {
  /// O tamanho exato (largura e altura) do ícone.
  ///
  /// Se for nulo, o widget assume as dimensões máximas do pai ou um fallback de 48.0.
  final double? size;

  /// Como a imagem deve ser inscrita na caixa do widget.
  ///
  /// Se for nulo, o comportamento padrão será determinado pela flag [fill]:
  /// * fill == true -> [BoxFit.cover]
  /// * fill == false -> [BoxFit.contain]
  final BoxFit? fit;

  /// Define a estratégia de dimensionamento e preenchimento.
  ///
  /// * Se true, o ícone expande-se para ocupar todo o espaço disponível (BoxFit.cover).
  /// * Se false (padrão), o tamanho é reduzido para 60% do espaço disponível (BoxFit.contain)
  /// para funcionar como um ícone padrão com padding interno.
  final bool fill;

  const NutriIcon({super.key, this.size, this.fit, this.fill = false});

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

  /// Constrói o widget de imagem base com recorte ([ClipRRect]) para evitar
  /// que o conteúdo ultrapasse os limites do container pai.
  Widget _buildImage(
    BuildContext context,
    double? targetSize,
    BoxFit fitStrategy,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_inheritRadius(context)),
      child: Image.asset(
        'assets/icon/icon_fill.png',
        width: targetSize,
        height: targetSize,
        fit: fitStrategy,
      ),
    );
  }

  /// Tenta identificar o contexto de renderização atual para herdar o raio
  /// de curvatura do container pai. Retorna 12.0 como fallback seguro.
  double _inheritRadius(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return 12.0;
    }
    return 0.0;
  }
}
