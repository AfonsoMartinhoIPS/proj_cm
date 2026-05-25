import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meal_entry_tile.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Detail view for a single day's nutrition log.
///
/// Entries are grouped by [MealType] (breakfast → lunch → dinner → snack);
/// each section shows its subtotal kcal. Tap an entry → edit. Trailing icon
/// → delete entry. App-bar delete icon → delete the whole day (with confirm).
///
/// When the log doesn't exist (or becomes empty after deleting the last
/// entry) the screen shows an empty state with an "add meal" CTA. We don't
/// auto-pop on empty so the user can still log a new entry for that date.
class DayDetailScreen extends ConsumerWidget {
  final String date;

  const DayDetailScreen({super.key, required this.date});

  String _formatDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: NutriLabel(
          title,
          variant: NutriLabelVariant.title,
          color: AppColors.onBackground,
        ),
        content: NutriLabel(
          body,
          variant: NutriLabelVariant.body,
          color: AppColors.textMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const NutriLabel(
              'Cancelar',
              variant: NutriLabelVariant.label,
              color: AppColors.textMuted,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const NutriLabel(
              'Apagar',
              variant: NutriLabelVariant.label,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(nutritionLogsProvider).value ?? [];
    final NutritionLog? log = logs.where((l) => l.date == date).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NutriTopNavBar(
        showBackButton: true,
        title: _formatDate(date),
        actions: [
          if (log != null && log.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Apagar dia',
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  title: 'Apagar dia?',
                  body: 'Vai remover todas as ${log.entries.length} '
                      'refeições registadas em ${_formatDate(date)}.',
                );
                if (!ok || !context.mounted) return;
                await ref
                    .read(nutritionLogsProvider.notifier)
                    .deleteDay(date);
                if (!context.mounted) return;
                context.pop();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: (log == null || log.entries.isEmpty)
            ? _EmptyState(date: date)
            : _Body(log: log, onConfirm: _confirm),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final NutritionLog log;
  final Future<bool> Function(
    BuildContext context, {
    required String title,
    required String body,
  }) onConfirm;

  const _Body({required this.log, required this.onConfirm});

  Map<MealType, List<MealEntry>> _grouped() {
    final m = <MealType, List<MealEntry>>{
      for (final t in MealType.values) t: [],
    };
    for (final e in log.entries) {
      m[e.mealType]!.add(e);
    }
    return m;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = _grouped();
    final notifier = ref.read(nutritionLogsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _DayTotalsCard(log: log),
        const SizedBox(height: AppSizes.md),
        for (final type in MealType.values)
          if (grouped[type]!.isNotEmpty)
            _MealTypeSection(
              type: type,
              entries: grouped[type]!,
              onEdit: (e) => context.push(
                '/meals/edit',
                extra: {'entry': e, 'date': log.date},
              ),
              onDelete: (e) async {
                final ok = await onConfirm(
                  context,
                  title: 'Apagar refeição?',
                  body: 'Remover "${e.productName}" deste dia.',
                );
                if (!ok) return;
                await notifier.removeEntry(e.id, date: log.date);
              },
            ),
        const SizedBox(height: AppSizes.md),
        NutriButton.transparent(
          label: '+ Adicionar refeição',
          onPressed: () => context.push('/meals/add'),
        ),
      ],
    );
  }
}

class _DayTotalsCard extends StatelessWidget {
  final NutritionLog log;

  const _DayTotalsCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final g = log.goals;
    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NutriLabel(
            'TOTAL DO DIA',
            variant: NutriLabelVariant.small,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSizes.sm),
          _MacroRow(label: 'Calorias',
              value: log.totalCalories, goal: g.calories.toDouble(),
              unit: 'kcal', color: AppColors.secondary),
          _MacroRow(label: 'Proteína',
              value: log.totalProtein, goal: g.protein.toDouble(),
              unit: 'g', color: AppColors.protein),
          _MacroRow(label: 'Hidratos',
              value: log.totalCarbs, goal: g.carbs.toDouble(),
              unit: 'g', color: AppColors.carbs),
          _MacroRow(label: 'Gordura',
              value: log.totalFat, goal: g.fat.toDouble(),
              unit: 'g', color: AppColors.fat),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NutriLabel(
              label,
              variant: NutriLabelVariant.body,
              color: AppColors.onBackground,
            ),
          ),
          NutriLabel(
            '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
            variant: NutriLabelVariant.small,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _MealTypeSection extends StatelessWidget {
  final MealType type;
  final List<MealEntry> entries;
  final void Function(MealEntry) onEdit;
  final void Function(MealEntry) onDelete;

  const _MealTypeSection({
    required this.type,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = entries.fold<double>(0, (s, e) => s + e.calories);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NutriCard(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.sm, AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.sm, right: AppSizes.sm, bottom: AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NutriLabel(
                    type.label.toUpperCase(),
                    variant: NutriLabelVariant.small,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                  NutriLabel(
                    '${subtotal.toStringAsFixed(0)} kcal',
                    variant: NutriLabelVariant.small,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            for (final e in entries)
              MealEntryTile(
                entry: e,
                onEdit: () => onEdit(e),
                onDelete: () => onDelete(e),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String date;

  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSizes.md),
            const NutriLabel(
              'Sem refeições registadas',
              variant: NutriLabelVariant.bodyLarge,
              color: AppColors.onBackground,
            ),
            const SizedBox(height: AppSizes.lg),
            NutriButton(
              label: '+ Adicionar refeição',
              onPressed: () => context.push('/meals/add'),
            ),
          ],
        ),
      ),
    );
  }
}
