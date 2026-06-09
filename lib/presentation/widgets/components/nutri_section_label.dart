import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Rótulo de secção com texto em maiúsculas e espaçamento entre letras.
///
/// Componente simples para cabeçalhos de secções em formulários e listas.
/// Aplica automaticamente a cor [ColorScheme.onSurfaceVariant] do tema atual.
class NutriSectionLabel extends StatelessWidget {
  /// O texto a ser exibido como rótulo.
  final String text;

  /// O espaçamento externo ao redor do rótulo.
  ///
  /// O valor padrão é uma margem esquerda de [AppSizes.sm].
  final EdgeInsetsGeometry padding;

  /// Cria uma [NutriSectionLabel].
  ///
  /// O parâmetro [text] é obrigatório.
  const NutriSectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(left: AppSizes.sm),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: NutriLabel(
        text,
        variant: NutriLabelVariant.small,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}