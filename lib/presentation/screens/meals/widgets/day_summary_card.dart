import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Cartão de resumo diário usado na lista de refeições.
///
/// Exibe a data (relativa para hoje/ontem), o número de entradas, o total de
/// calorias e a percentagem da meta diária atingida. Inclui ações para abrir
/// o detalhe do dia ([onTap]) e para apagar o dia ([onDelete]).
class DaySummaryCard extends StatelessWidget {
  /// O registo de nutrição do dia a ser resumido.
  final NutritionLog log;

  /// Callback invocado quando o cartão é tocado (abre o detalhe do dia).
  final VoidCallback onTap;

  /// Callback invocado quando o ícone de apagar é pressionado.
  final VoidCallback onDelete;

  /// Cria um [DaySummaryCard].
  ///
  /// Os parâmetros [log], [onTap] e [onDelete] são obrigatórios.
  const DaySummaryCard({
    super.key,
    required this.log,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = log.entries.length;
    final kcal = log.totalCalories.toStringAsFixed(0);
    final goal = log.goals.calories;
    final pct = goal > 0
        ? ((log.totalCalories / goal) * 100).clamp(0, 999).toStringAsFixed(0)
        : '-';

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
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 4),
                      NutriLabel(
                        '$entries ${entries == 1 ? 'item' : 'itens'}  ·  $kcal kcal  ·  $pct%',
                        variant: NutriLabelVariant.small,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Apagar dia',
                  onPressed: onDelete,
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}