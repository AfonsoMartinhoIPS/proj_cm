import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/day_summary_card.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Top-level meals screen: list of recent days. Tapping a day opens
/// [DayDetailScreen]; the trailing icon on each card deletes the whole day
/// (with confirm).
///
/// Days with no entries are filtered out so the list stays clean.
class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, NutritionLog log) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const NutriLabel(
          'Apagar dia?',
          variant: NutriLabelVariant.title,
          color: AppColors.onBackground,
        ),
        content: NutriLabel(
          'Vai remover ${log.entries.length} '
          '${log.entries.length == 1 ? 'refeição' : 'refeições'} '
          'registadas em ${log.date}.',
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
    final async = ref.watch(nutritionLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NutriTopNavBar(showBackButton: false, title: 'Refeições'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => context.push('/meals/add'),
        child: const Icon(Icons.add),
      ),
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

            if (withEntries.isEmpty) return const _EmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: withEntries.length,
              itemBuilder: (context, i) {
                final log = withEntries[i];
                return DaySummaryCard(
                  log: log,
                  onTap: () => context.push('/meals/day/${log.date}'),
                  onDelete: () async {
                    final ok = await _confirmDelete(context, log);
                    if (!ok) return;
                    await ref
                        .read(nutritionLogsProvider.notifier)
                        .deleteDay(log.date);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              'Nenhuma refeição registada',
              variant: NutriLabelVariant.bodyLarge,
              color: AppColors.onBackground,
            ),
            const SizedBox(height: AppSizes.sm),
            const NutriLabel(
              'Toca em + para começar.',
              variant: NutriLabelVariant.body,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
