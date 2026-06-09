// lib/presentation/screens/meals/meals_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/history/history_helpers.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meals_timeline.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Filtros temporais disponíveis para a timeline de refeições.
///
/// Cada valor define uma janela rolante terminada em "hoje". Não há
/// navegação prev/next — esse caso de uso vive no `HistoryScreen`. Aqui o
/// foco é "ver as minhas últimas refeições" sem ter que escolher datas.
enum _Range {
  today(days: 1, label: 'Hoje'),
  week(days: 7, label: 'Semana'),
  month(days: null, label: 'Mês'),
  all(days: null, label: 'Tudo');

  const _Range({required this.days, required this.label});

  /// Quantidade de dias a incluir a contar a partir de hoje (inclusive).
  /// `null` significa "tudo o que o provider já carregou".
  final int? days;
  final String label;
}

/// Ecrã principal de refeições.
///
/// Mostra uma timeline contínua com todos os dias filtrados pela `_Range`
/// selecionada, do mais recente para o mais antigo. Cada dia aparece
/// expandido com as suas entradas — o utilizador vê várias refeições de
/// vários dias sem precisar de tocar dia a dia.
///
/// Funcionalidades:
///   * Chips no topo (Hoje / Semana / Mês / Tudo) filtram a janela rolante.
///   * Cabeçalho da janela: total kcal + nº refeições + nº dias com registos.
///   * Pull-to-refresh força refetch.
///   * Paginação automática quando o utilizador chega ao fim do scroll
///     (no modo "Tudo"); modos com janela fixa não precisam.
///   * FAB para adicionar refeição (data padrão = hoje).
///
/// Vistas agregadas, calendário e estatísticas vivem no `HistoryScreen`.
class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  final _scrollController = ScrollController();
  bool _loadingMore = false;
  _Range _range = _Range.week;

  /// Mês mostrado quando `_range == _Range.month`. Default = mês atual.
  /// Mutado pelos chevrons no `_MonthNavigator`. Não usado nos outros modos.
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    setupScrollPagination(
      controller: _scrollController,
      isActive: () => _range == _Range.all,
      onLoadMore: _loadMore,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      await ref.read(nutritionLogsProvider.notifier).loadMore();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    final notifier = ref.read(nutritionLogsProvider.notifier);
    await notifier.setRange(notifier.daysLoaded);
  }

  /// Quando o utilizador navega para um mês passado que ainda não está
  /// no range carregado, expande o `daysLoaded` do provider para cobrir
  /// até ao primeiro dia desse mês. Fire-and-forget: se a rede falhar,
  /// o utilizador vê o estado vazio + pode tentar de novo via
  /// pull-to-refresh.
  Future<void> _ensureMonthLoaded(DateTime month) async {
    final notifier = ref.read(nutritionLogsProvider.notifier);
    final today = DateTime.now();
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysBack = today.difference(firstOfMonth).inDays + 1;
    if (daysBack <= notifier.daysLoaded) return;
    await notifier.setRange(daysBack);
  }

  void _shiftMonth(int by) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + by);
    });
    _ensureMonthLoaded(_displayMonth);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _displayMonth.year == now.year && _displayMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(nutritionLogsProvider);

    return Scaffold(
      appBar: const NutriTopNavBar(showBackButton: false, title: 'Refeições'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => context.push('/meals/add'),
        tooltip: 'Adicionar refeição',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: NutriLabel(
              'Erro a carregar refeições',
              variant: NutriLabelVariant.body,
              color: colorScheme.error,
            ),
          ),
          data: (logs) {
            final filtered = filterLogs(
              logs,
              daysBack: _range.days,
              month: _range == _Range.month ? _displayMonth : null,
            );
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NutriChipSelector<_Range>(
                      items: _Range.values,
                      selected: _range,
                      onChanged: (r) {
                        setState(() {
                          _range = r;
                          // Ao voltar para "Mês", reset para o mês atual
                          // — evita ficar preso num mês antigo escolhido
                          // anteriormente.
                          if (r == _Range.month) {
                            final now = DateTime.now();
                            _displayMonth = DateTime(now.year, now.month);
                          }
                        });
                      },
                      label: (r) => r.label,
                    ),
                    if (_range == _Range.month) ...[
                      const SizedBox(height: AppSizes.sm),
                      _MonthNavigator(
                        month: _displayMonth,
                        onPrev: () => _shiftMonth(-1),
                        // Bloqueia avançar para o futuro: não faz sentido
                        // ver refeições de um mês que ainda não chegou.
                        onNext:
                            _isCurrentMonth ? null : () => _shiftMonth(1),
                      ),
                    ],
                    const SizedBox(height: AppSizes.md),
                    _PeriodSummary(logs: filtered),
                    const SizedBox(height: AppSizes.md),
                    MealsTimeline(
                      logs: filtered,
                      onDayTap: (log) =>
                          context.push('/meals/day/${log.date}'),
                      onDayDelete: (log) =>
                          confirmDeleteDay(context, log, ref),
                    ),
                    if (_loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Barra de navegação por mês (chevrons + nome do mês). Aparece só quando
/// `_range == _Range.month`. `onNext == null` desativa o chevron direito
/// (mês atual — não há mais nada para a frente).
class _MonthNavigator extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthNavigator({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: colorScheme.onSurface,
          tooltip: 'Mês anterior',
          onPressed: onPrev,
        ),
        NutriLabel(
          '${ptMonthsFull[month.month - 1]} ${month.year}',
          variant: NutriLabelVariant.bodyLarge,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: onNext == null
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
              : colorScheme.onSurface,
          tooltip: 'Mês seguinte',
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Linha de resumo do período: nº dias com registos · nº refeições · kcal
/// totais. Dá contexto imediato sem o utilizador ter de somar mentalmente.
class _PeriodSummary extends StatelessWidget {
  final List<NutritionLog> logs;

  const _PeriodSummary({required this.logs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final withEntries = logs.where((l) => l.entries.isNotEmpty);
    final days = withEntries.length;
    final entries = withEntries.fold<int>(0, (s, l) => s + l.entries.length);
    final kcal = withEntries
        .fold<double>(0, (s, l) => s + l.totalCalories)
        .toStringAsFixed(0);

    return NutriLabel(
      days == 0
          ? 'Sem registos neste período'
          : '$days ${days == 1 ? 'dia' : 'dias'} · $entries '
                '${entries == 1 ? 'refeição' : 'refeições'} · $kcal kcal',
      variant: NutriLabelVariant.small,
      color: colorScheme.onSurfaceVariant,
    );
  }
}