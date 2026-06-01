import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/day_summary_card.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Nutrition history view.
///
/// Layout:
///   1. Range chips (7d / 30d / 90d) drive `setRange` on the provider.
///   2. Stats card with avg kcal/day, days with entries, total meal entries.
///   3. Newest-first list of [DaySummaryCard] (empty days filtered out).
///
/// Reuses every existing piece — no new providers, no new repository calls,
/// no chart library. Tapping a day opens [DayDetailScreen] via `/meals/day/:date`.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

/// The three range presets exposed in the chip selector. Days values match
/// what's passed to `setRange`. Keep in sync with [_rangeLabel].
enum _Range { week, month, quarter }

extension on _Range {
  int get days => switch (this) {
        _Range.week => 7,
        _Range.month => 30,
        _Range.quarter => 90,
      };

  String get label => switch (this) {
        _Range.week => '7 dias',
        _Range.month => '30 dias',
        _Range.quarter => '90 dias',
      };
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Range _range = _Range.week;

  @override
  void initState() {
    super.initState();
    // Sync provider range to whatever the screen opens at. The provider
    // remembers its window across nav (so meals screen + home see the same
    // data), but history users typically expect a fresh range on entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setRange(_range, refetch: true);
    });
  }

  void _setRange(_Range r, {bool refetch = true}) {
    setState(() => _range = r);
    if (refetch) {
      ref.read(nutritionLogsProvider.notifier).setRange(r.days);
    }
  }

  Future<void> _confirmDelete(NutritionLog log) async {
    final ok = await showNutriConfirmDialog(
      context,
      title: 'Apagar dia?',
      body: 'Vai remover ${log.entries.length} '
          '${log.entries.length == 1 ? 'refeição' : 'refeições'} '
          'registadas em ${formatRelativeDate(log.date)}.',
    );
    if (!ok) return;
    await ref.read(nutritionLogsProvider.notifier).deleteDay(log.date);
    if (!mounted) return;
    NutriFeedback.showInfo(context, 'Dia removido');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(nutritionLogsProvider);

    return Scaffold(
      appBar: const NutriTopNavBar(showBackButton: true, title: 'Histórico'),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: NutriLabel(
              'Erro: $e',
              variant: NutriLabelVariant.body,
              color: AppColors.error,
            ),
          ),
          data: (logs) {
            final withEntries = [
              for (final l in logs) if (l.entries.isNotEmpty) l,
            ]..sort((a, b) => b.date.compareTo(a.date));

            return ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                _RangePicker(
                  selected: _range,
                  onChanged: (r) => _setRange(r),
                ),
                const SizedBox(height: AppSizes.md),
                _StatsRow(logs: withEntries, totalDays: _range.days),
                const SizedBox(height: AppSizes.md),
                if (withEntries.isEmpty)
                  const _EmptyState()
                else
                  for (final log in withEntries)
                    DaySummaryCard(
                      log: log,
                      onTap: () => context.push('/meals/day/${log.date}'),
                      onDelete: () => _confirmDelete(log),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RangePicker extends StatelessWidget {
  final _Range selected;
  final ValueChanged<_Range> onChanged;

  const _RangePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: NutriChipSelector<_Range>(
        items: _Range.values,
        selected: selected,
        onChanged: onChanged,
        label: (r) => r.label,
      ),
    );
  }
}

/// Three stat cards in a row: average kcal/day across days with entries,
/// adherence (logged days / total days in range), total meals logged.
///
/// Average uses only days that have entries — zero-entry days would skew
/// the mean toward 0 and misrepresent typical intake.
class _StatsRow extends StatelessWidget {
  final List<NutritionLog> logs;
  final int totalDays;

  const _StatsRow({required this.logs, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final loggedDays = logs.length;
    final totalEntries = logs.fold<int>(0, (s, l) => s + l.entries.length);
    final avgKcal = loggedDays == 0
        ? 0
        : logs.fold<double>(0, (s, l) => s + l.totalCalories) / loggedDays;

    return Row(
      children: [
        Expanded(
          child: NutriStatCard(
            label: 'Média kcal',
            value: avgKcal.toStringAsFixed(0),
            subvalue: 'por dia registado',
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: NutriStatCard(
            label: 'Dias registados',
            value: '$loggedDays/$totalDays',
            subvalue: 'no período',
            icon: Icons.calendar_today,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: NutriStatCard(
            label: 'Refeições',
            value: '$totalEntries',
            subvalue: 'total',
            icon: Icons.restaurant,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl * 2),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.md),
          NutriLabel(
            'Nenhuma refeição registada neste período',
            variant: NutriLabelVariant.body,
            color: colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
