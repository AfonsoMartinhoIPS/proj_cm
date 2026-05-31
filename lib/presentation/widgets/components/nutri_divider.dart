import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Divisor horizontal ou vertical customizável.
///
/// Componente para separar secções de conteúdo com espaçamento,
/// cor e orientação personalizados. Por predefinição renderiza
/// uma linha horizontal fina com a cor de contorno do tema.
class NutriDivider extends StatelessWidget {
  /// Altura do espaço ocupado pelo divisor (horizontal) ou largura (vertical).
  final double height;

  /// Espessura da linha do divisor.
  final double thickness;

  /// Cor da linha.
  ///
  /// Se não for especificada, utiliza [ColorScheme.outline].
  final Color? color;

  /// Espaçamento externo ao redor do divisor.
  final EdgeInsetsGeometry padding;

  /// Direção do divisor.
  ///
  /// [Axis.horizontal] (padrão) desenha uma linha horizontal;
  /// [Axis.vertical] desenha uma linha vertical.
  final Axis direction;

  /// Cria um [NutriDivider].
  const NutriDivider({
    super.key,
    this.height = 1,
    this.thickness = 1,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: AppSizes.sm),
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).colorScheme.outline;

    return Padding(
      padding: padding,
      child: direction == Axis.horizontal
          ? Divider(
              height: height,
              thickness: thickness,
              color: dividerColor,
            )
          : VerticalDivider(
              width: height,
              thickness: thickness,
              color: dividerColor,
            ),
    );
  }
}