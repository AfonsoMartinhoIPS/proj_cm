import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Seletor genérico de chips para enumerar ou listar seleções.
///
/// Componente reutilizável para seleção de um item entre múltiplas opções.
/// Suporta qualquer tipo genérico T com função de label customizável.
class NutriChipSelector<T> extends StatelessWidget {
  final List<T> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T) label;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  const NutriChipSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.label,
    this.spacing = 8,
    this.runSpacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => onChanged(item),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: NutriLabel(
              label(item),
              variant: NutriLabelVariant.small,
              color: isSelected ? AppColors.onBackground : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
