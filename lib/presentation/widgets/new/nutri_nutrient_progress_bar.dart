import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Barra de progresso de nutrientes (proteína, carbos, gordura) com valores.
///
/// Exibe o progresso visual de um nutriente específico com rótulo, valor atual,
/// meta e percentagem opcional.
class NutriNutrientProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final bool showPercentage;

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
              color: AppColors.textMuted,
            ),
            if (showPercentage)
              NutriLabel(
                '$percentage%',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceDark,
            color: color,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        NutriLabel(
          '${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}',
          variant: NutriLabelVariant.small,
          color: AppColors.textMuted,
        ),
      ],
    );
  }
}
