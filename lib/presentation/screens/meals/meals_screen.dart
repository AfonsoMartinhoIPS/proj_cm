import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/day_summary_card.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Top-level meals screen.
///
/// Shows recent days as cards (newest first). Features:
///   * **Search** - filter days by entry product name (case-insensitive
///     substring match on any entry).
///   * **Pagination** - when the user scrolls within 200px of the bottom and
///     no fetch is in flight, the screen calls
///     [NutritionLogsNotifier.loadMore] to extend the window by 7 days.
///   * **Per-card delete** - trailing icon on each card opens a confirm dialog
///     then removes the whole day via `deleteDay`.
///
/// Empty days are filtered out of the list (the auto-cleanup in the provider
/// already deletes truly empty docs, but `state.value` may still contain
/// stale entries until the next refresh).
class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Triggers `loadMore` when the user scrolls within 200px of the list
  /// bottom. Guarded by [_loadingMore] so back-to-back scroll events don't
  /// stack multiple fetches.
  void _onScroll() {
    if (_loadingMore) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await ref.read(nutritionLogsProvider.notifier).loadMore();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool _matchesQuery(NutritionLog log) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return log.entries.any((e) => e.productName.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
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
            final filtered = [
              for (final l in logs)
                if (l.entries.isNotEmpty && _matchesQuery(l)) l,
            ]..sort((a, b) => b.date.compareTo(a.date));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm,
                  ),
                  child: NutriTextField(
                    label: 'Pesquisar',
                    hint: 'Nome do produto…',
                    icon: Icons.search,
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(hasQuery: _query.isNotEmpty)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.md, AppSizes.sm,
                            AppSizes.md, AppSizes.xl,
                          ),
                          itemCount: filtered.length + 1,
                          itemBuilder: (context, i) {
                            if (i == filtered.length) {
                              return _loadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSizes.md,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }
                            final log = filtered[i];
                            return DaySummaryCard(
                              log: log,
                              onTap: () => context.push('/meals/day/${log.date}'),
                              onDelete: () async {
                                final ok = await showNutriConfirmDialog(
                                  context,
                                  title: 'Apagar dia?',
                                  body: 'Vai remover ${log.entries.length} '
                                      '${log.entries.length == 1 ? 'refeição' : 'refeições'} '
                                      'registadas em ${formatRelativeDate(log.date)}.',
                                );
                                if (!ok) return;
                                await ref
                                    .read(nutritionLogsProvider.notifier)
                                    .deleteDay(log.date);
                                if (!context.mounted) return;
                                NutriFeedback.showInfo(context, 'Dia removido');
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;

  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.restaurant_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSizes.md),
            NutriLabel(
              hasQuery
                  ? 'Sem resultados'
                  : 'Nenhuma refeição registada',
              variant: NutriLabelVariant.bodyLarge,
              color: AppColors.onBackground,
            ),
            const SizedBox(height: AppSizes.sm),
            NutriLabel(
              hasQuery
                  ? 'Tenta outra pesquisa.'
                  : 'Toca em + para começar.',
              variant: NutriLabelVariant.body,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
