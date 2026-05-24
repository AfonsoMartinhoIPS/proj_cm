// presentation/widgets/new/nutri_label.dart

import 'package:flutter/material.dart';

/// Enum para mapear os estilos de texto definidos no teu AppTheme.
enum NutriLabelVariant {
  display,    // displaySmall
  headline,   // headlineMedium
  title,      // titleLarge
  bodyLarge,  // bodyLarge
  body,       // bodyMedium
  small,      // bodySmall
  label,      // labelLarge
}

class NutriLabel extends StatelessWidget {
  final String? text;
  final InlineSpan? textSpan; // Suporte para Text.rich
  final NutriLabelVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;

  const NutriLabel(
    this.text, {
    super.key,
    this.variant = NutriLabelVariant.body,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
  }) : textSpan = null;

  /// Construtor para suportar árvores de TextSpan complexas (ex: marcas bi-color)
  const NutriLabel.rich(
    this.textSpan, {
    super.key,
    this.variant = NutriLabelVariant.body,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
  }) : text = null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Resolve o estilo base do teu TextTheme centralizado
    final baseStyle = switch (variant) {
      NutriLabelVariant.display => textTheme.displaySmall,
      NutriLabelVariant.headline => textTheme.headlineMedium,
      NutriLabelVariant.title => textTheme.titleLarge,
      NutriLabelVariant.bodyLarge => textTheme.bodyLarge,
      NutriLabelVariant.body => textTheme.bodyMedium,
      NutriLabelVariant.small => textTheme.bodySmall,
      NutriLabelVariant.label => textTheme.labelLarge,
    };

    final finalStyle = baseStyle?.copyWith(
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );

    if (textSpan != null) {
      return Text.rich(
        textSpan!,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: finalStyle,
      );
    }

    return Text(
      text ?? '',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: finalStyle,
    );
  }
}