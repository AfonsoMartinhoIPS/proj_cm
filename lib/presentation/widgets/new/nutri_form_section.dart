import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_card.dart';

/// Secção de formulário agrupada com título e conteúdo em card.
///
/// Wrapper para agrupar campos de formulário relacionados com estilo consistente.
class NutriFormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment mainAxisAlignment;

  const NutriFormSection({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return NutriCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
