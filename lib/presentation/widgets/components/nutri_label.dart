import 'package:flutter/material.dart';

/// Mapeia os estilos de texto do tema da aplicação.
///
/// Cada valor corresponde a um estilo do [TextTheme] utilizado pelo [NutriLabel].
enum NutriLabelVariant {
  /// Estilo de destaque principal (displaySmall).
  display,

  /// Estilo de cabeçalho (headlineMedium).
  headline,

  /// Estilo de título (titleLarge).
  title,

  /// Corpo de texto grande (bodyLarge).
  bodyLarge,

  /// Corpo de texto padrão (bodyMedium).
  body,

  /// Texto secundário pequeno (bodySmall).
  small,

  /// Rótulo com ênfase (labelLarge).
  label,
}

/// Rótulo de texto estilizado que utiliza a tipografia do tema.
///
/// Substitui o uso direto de [Text] com estilos do [TextTheme], garantindo
/// consistência visual em toda a aplicação. Suporta tanto texto simples
/// como construções ricas com [TextSpan].
class NutriLabel extends StatelessWidget {
  /// Texto simples a ser exibido.
  ///
  /// Ignorado quando [textSpan] é fornecido.
  final String? text;

  /// Árvore de [TextSpan] para construções de texto complexas (ex.: texto bicolor).
  ///
  /// Tem prioridade sobre [text].
  final InlineSpan? textSpan;

  /// Variante tipográfica que determina o estilo base do texto.
  ///
  /// O valor padrão é [NutriLabelVariant.body].
  final NutriLabelVariant variant;

  /// Cor do texto.
  ///
  /// Se não for especificada, utiliza a cor definida no estilo base do tema.
  final Color? color;

  /// Alinhamento do texto.
  final TextAlign? textAlign;

  /// Espessura da fonte.
  ///
  /// Sobrepõe o valor definido no estilo base do tema.
  final FontWeight? fontWeight;

  /// Espaçamento adicional entre caracteres.
  final double? letterSpacing;

  /// Número máximo de linhas antes do truncamento.
  final int? maxLines;

  /// Comportamento visual quando o texto excede [maxLines].
  final TextOverflow? overflow;

  /// Cria um [NutriLabel] com texto simples.
  ///
  /// O parâmetro [text] é obrigatório neste construtor.
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

  /// Cria um [NutriLabel] com uma árvore de [TextSpan].
  ///
  /// Útil para textos que exigem estilos mistos (ex.: "NutriScan" com duas cores).
  /// O parâmetro [textSpan] é obrigatório neste construtor.
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