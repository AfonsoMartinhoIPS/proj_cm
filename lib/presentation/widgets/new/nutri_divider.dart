import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Divisor horizontal ou vertical customizável.
///
/// Componente para separar seções de conteúdo com espaçamento e cor personalizados.
class NutriDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Axis direction;

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
    final dividerColor = color ?? AppColors.border;

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
