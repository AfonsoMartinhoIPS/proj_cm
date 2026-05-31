import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Barra de progresso para um nutriente específico.
///
/// Exibe o nome do nutriente, uma barra de progresso linear que compara o
/// valor atual ([current]) com a meta ([goal]), e a relação numérica entre
/// ambos. Opcionalmente pode mostrar a percentagem atingida.
class NutriNutrientProgressBar extends StatelessWidget {
  /// Nome do nutriente (ex.: "Proteína").
  final String label;

  /// Valor atual já consumido.
  final double current;

  /// Meta diária definida para o nutriente.
  final double goal;

  /// Cor da barra de progresso.
  final Color color;

  /// Se `true`, exibe a percentagem atingida à direita do rótulo.
  ///
  /// O valor padrão é `false`.
  final bool showPercentage;

  /// Cria uma [NutriNutrientProgressBar].
  ///
  /// Os parâmetros [label], [current], [goal] e [color] são obrigatórios.
  const NutriNutrientProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NutriLabel(
              label.toUpperCase(),
              variant: NutriLabelVariant.small,
              color: colorScheme.onSurfaceVariant,
            ),
            if (showPercentage)
              NutriLabel(
                '$percentage%',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        NutriLabel(
          '${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}',
          variant: NutriLabelVariant.small,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}