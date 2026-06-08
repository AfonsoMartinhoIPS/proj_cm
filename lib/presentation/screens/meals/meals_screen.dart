import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
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
  month(days: 30, label: 'Mês'),
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Paginação só faz sentido quando estamos a ver "Tudo" — nos outros
    // modos a janela já está delimitada, não há mais a carregar.
    if (_range != _Range.all) return;
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

  Future<void> _refresh() async {
    final notifier = ref.read(nutritionLogsProvider.notifier);
    await notifier.setRange(notifier.daysLoaded);
  }

  /// Filtra a lista bruta de logs pela `_Range` selecionada.
  ///
  /// `_Range.all` devolve sem alterações; os outros modos cortam por uma
  /// janela rolante de [_Range.days] dias terminada em "hoje".
  List<NutritionLog> _filter(List<NutritionLog> logs) {
    final days = _range.days;
    if (days == null) return logs;
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return logs.where((l) {
      final d = DateTime.tryParse(l.date);
      if (d == null) return false;
      return !d.isBefore(cutoff);
    }).toList();
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
            final filtered = _filter(logs);
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
                      onChanged: (r) => setState(() => _range = r),
                      label: (r) => r.label,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _PeriodSummary(logs: filtered),
                    const SizedBox(height: AppSizes.md),
                    MealsTimeline(
                      logs: filtered,
                      onDayTap: (log) =>
                          context.push('/meals/day/${log.date}'),
                      onEntryTap: (log, entry) => context.push(
                        '/meals/edit',
                        extra: {'entry': entry, 'date': log.date},
                      ),
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
