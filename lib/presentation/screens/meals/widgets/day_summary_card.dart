import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Compact summary of a [NutritionLog] for the meals list.
///
/// Shows the date (relative for today/yesterday), entry count, total kcal,
/// and a goal-percent badge. Tapping the card invokes [onTap] (open detail);
/// the trailing more-button invokes [onDelete] (confirm + delete day).
class DaySummaryCard extends StatelessWidget {
  final NutritionLog log;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DaySummaryCard({
    super.key,
    required this.log,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final entries = log.entries.length;
    final kcal = log.totalCalories.toStringAsFixed(0);
    final goal = log.goals.calories;
    final pct = goal > 0
        ? ((log.totalCalories / goal) * 100).clamp(0, 999).toStringAsFixed(0)
        : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          onTap: onTap,
          child: NutriCard(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.md, AppSizes.sm, AppSizes.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutriLabel(
                        formatRelativeDate(log.date),
                        variant: NutriLabelVariant.bodyLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                      const SizedBox(height: 4),
                      NutriLabel(
                        '$entries ${entries == 1 ? 'item' : 'itens'}  ·  $kcal kcal  ·  $pct%',
                        variant: NutriLabelVariant.small,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.textMuted,
                  tooltip: 'Apagar dia',
                  onPressed: onDelete,
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
