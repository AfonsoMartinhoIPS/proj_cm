import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_card.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Secção de formulário agrupada com título e conteúdo.
///
/// Envolve os [children] num [NutriCard] com um título estilizado no topo.
/// Útil para agrupar campos de formulário relacionados com um visual consistente.
class NutriFormSection extends StatelessWidget {
  /// O título exibido no topo da secção.
  final String title;

  /// Os widgets que compõem o conteúdo do formulário.
  final List<Widget> children;

  /// O espaçamento interno do card.
  ///
  /// O valor padrão é [AppSizes.md] em todos os lados.
  final EdgeInsetsGeometry padding;

  /// Como os [children] são alinhados ao longo do eixo principal.
  ///
  /// O valor padrão é [MainAxisAlignment.start].
  final MainAxisAlignment mainAxisAlignment;

  /// Cria uma [NutriFormSection].
  ///
  /// Os parâmetros [title] e [children] são obrigatórios.
  const NutriFormSection({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NutriCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: NutriLabel(
              title,
              variant: NutriLabelVariant.small,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}