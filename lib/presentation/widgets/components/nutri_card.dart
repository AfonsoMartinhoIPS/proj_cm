import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Variante de cor para o [NutriCard].
///
/// * [surface] utiliza a cor de superfície primária do tema.
/// * [surfaceDark] utiliza a cor de superfície secundária (container mais escuro).
enum NutriCardVariant { surface, surfaceDark }

/// Cartão de superfície padronizado com cantos arredondados e borda.
///
/// Componente base para agrupar conteúdo com estilo consistente.
/// Suporta duas variantes de cor ([surface] e [surfaceDark]) e permite
/// personalizar o padding, a margem e o raio dos cantos.
class NutriCard extends StatelessWidget {
  /// O conteúdo a ser exibido dentro do cartão.
  final Widget child;

  /// O espaçamento interno entre a borda do cartão e o [child].
  ///
  /// O valor padrão é [AppSizes.md].
  final EdgeInsetsGeometry padding;

  /// A variante de cor do cartão.
  ///
  /// O valor padrão é [NutriCardVariant.surface].
  final NutriCardVariant variant;

  /// O raio dos cantos do cartão.
  ///
  /// Se não for especificado, utiliza [AppSizes.radiusLg].
  final BorderRadiusGeometry? borderRadius;

  /// A margem externa ao redor do cartão.
  final EdgeInsetsGeometry? margin;

  /// Cria um [NutriCard].
  ///
  /// O parâmetro [child] é obrigatório.
  const NutriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.variant = NutriCardVariant.surface,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bg = variant == NutriCardVariant.surfaceDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outline),
      ),
      child: child,
    );
  }
}