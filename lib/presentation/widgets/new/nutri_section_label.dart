import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Rótulo de secção com texto em maiúscula e espaçamento entre letras.
///
/// Componente simples para cabeçalhos de seções em formulários e listas.
class NutriSectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const NutriSectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(left: AppSizes.sm),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: NutriLabel(
        text,
        variant: NutriLabelVariant.small,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
      ),
    );
  }
}
