import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Seletor genérico de chips para escolha única entre múltiplas opções.
///
/// Renderiza uma lista de chips dispostos num [Wrap], onde o utilizador
/// pode selecionar um item de entre os fornecidos em [items].
///
/// Tipo genérico [T] — o tipo dos itens a selecionar.
class NutriChipSelector<T> extends StatelessWidget {
  /// A lista de itens disponíveis para seleção.
  final List<T> items;

  /// O item atualmente selecionado.
  final T selected;

  /// Callback invocado quando o utilizador seleciona um novo item.
  final ValueChanged<T> onChanged;

  /// Função que converte um item do tipo [T] na sua representação textual.
  final String Function(T) label;

  /// Espaçamento horizontal entre chips.
  final double spacing;

  /// Espaçamento vertical entre linhas de chips.
  final double runSpacing;

  /// Padding interno de cada chip.
  final EdgeInsetsGeometry padding;

  /// Cria um [NutriChipSelector].
  ///
  /// Os parâmetros [items], [selected], [onChanged] e [label] são obrigatórios.
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
    final colorScheme = Theme.of(context).colorScheme;
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
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
            ),
            child: NutriLabel(
              label(item),
              variant: NutriLabelVariant.small,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}