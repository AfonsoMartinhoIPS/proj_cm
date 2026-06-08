import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Timeline plana de refeições, agrupada por dia.
///
/// Renderiza, do dia mais recente para o mais antigo, uma secção por dia
/// expandida com todas as entradas — em vez de obrigar o utilizador a
/// escolher um dia de cada vez. Resolve o "só vejo uma refeição por
/// página" que estava a tornar o ecrã de refeições inutilizável.
///
///   * Cabeçalho da data (clicável): data relativa + total kcal +
///     contagem de entradas. Toca para abrir o detalhe do dia.
///   * Linha por entrada: chip colorido por tipo de refeição
///     ([NutriTag]), nome, gramas e calorias. Toca para editar.
///
/// Dias sem entradas são filtrados — auto-cleanup do provider já remove
/// docs vazios, mas o widget também filtra defensivamente.
class MealsTimeline extends StatelessWidget {
  final List<NutritionLog> logs;

  /// Toca no cabeçalho da data → abrir detalhe do dia.
  final void Function(NutritionLog log) onDayTap;

  /// Toca numa entrada individual → abrir edição.
  final void Function(NutritionLog log, MealEntry entry) onEntryTap;

  const MealsTimeline({
    super.key,
    required this.logs,
    required this.onDayTap,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    final withEntries = [
      for (final l in logs) if (l.entries.isNotEmpty) l,
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (withEntries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: NutriEmptyState(
          icon: Icons.restaurant_outlined,
          title: 'Sem refeições registadas',
          subtitle: 'Toca em + para começar a registar.',
        ),
      );
    }

    return Column(
      children: [
        for (final log in withEntries)
          _DaySection(
            log: log,
            onDayTap: () => onDayTap(log),
            onEntryTap: (e) => onEntryTap(log, e),
          ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  final NutritionLog log;
  final VoidCallback onDayTap;
  final ValueChanged<MealEntry> onEntryTap;

  const _DaySection({
    required this.log,
    required this.onDayTap,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final kcal = log.totalCalories.toStringAsFixed(0);
    final count = log.entries.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NutriCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onDayTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.sm,
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
                          const SizedBox(height: 2),
                          NutriLabel(
                            '$count ${count == 1 ? 'item' : 'itens'} · $kcal kcal',
                            variant: NutriLabelVariant.small,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const NutriDivider(),
            for (final entry in log.entries)
              _EntryRow(entry: entry, onTap: () => onEntryTap(entry)),
            const SizedBox(height: AppSizes.xs),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onTap;

  const _EntryRow({required this.entry, required this.onTap});

  NutriTagVariant _tagVariant(MealType type) => switch (type) {
        MealType.breakfast => NutriTagVariant.warning,
        MealType.lunch => NutriTagVariant.primary,
        MealType.dinner => NutriTagVariant.secondary,
        MealType.snack => NutriTagVariant.success,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grams = entry.servingGrams.toStringAsFixed(0);
    final kcal = entry.calories.toStringAsFixed(0);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            NutriTag(
              label: entry.mealType.label,
              variant: _tagVariant(entry.mealType),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    entry.productName,
                    variant: NutriLabelVariant.body,
                    color: colorScheme.onSurface,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  NutriLabel(
                    '${grams}g',
                    variant: NutriLabelVariant.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            NutriLabel(
              '$kcal kcal',
              variant: NutriLabelVariant.small,
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
