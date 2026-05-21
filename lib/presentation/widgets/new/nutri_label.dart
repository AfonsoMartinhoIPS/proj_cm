import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Visual variants for [NutriLabel].
///
/// - [section] — small uppercase header above grouped content
///   (e.g. "NOTIFICAÇÕES", "OBJETIVOS DIÁRIOS", "NOTAS").
/// - [field] — even smaller uppercase label above form inputs
///   (e.g. "EMAIL", "PESO (KG)").
/// - [caption] — non-uppercased muted body text for inline hints
///   (e.g. "de 1580 kcal", "Guardado em 12/05/2026").
enum NutriLabelVariant { section, field, caption }

/// Reusable text label that enforces the project's typographic conventions
/// for section headers, form labels and captions. Always coloured with
/// [AppColors.textMuted] unless [color] is provided.
class NutriLabel extends StatelessWidget {
  final String text;
  final NutriLabelVariant variant;
  final Color? color;
  final TextAlign? textAlign;

  const NutriLabel(
    this.text, {
    super.key,
    this.variant = NutriLabelVariant.section,
    this.color,
    this.textAlign,
  });

  /// Convenience constructor for section headers ("NOTIFICAÇÕES").
  const NutriLabel.section(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
  }) : variant = NutriLabelVariant.section;

  /// Convenience constructor for form field labels ("EMAIL").
  const NutriLabel.field(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
  }) : variant = NutriLabelVariant.field;

  /// Convenience constructor for inline caption text.
  const NutriLabel.caption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
  }) : variant = NutriLabelVariant.caption;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? AppColors.textMuted;
    final style = switch (variant) {
      NutriLabelVariant.section => TextStyle(
          color: resolved,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      NutriLabelVariant.field => TextStyle(
          color: resolved,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      NutriLabelVariant.caption => TextStyle(
          color: resolved,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
    };

    // section and field are conventionally uppercased — caption is rendered as-is.
    final rendered = variant == NutriLabelVariant.caption
        ? text
        : text.toUpperCase();

    return Text(rendered, style: style, textAlign: textAlign);
  }
}
