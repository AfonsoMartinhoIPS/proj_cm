import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meals_timeline.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã principal de refeições.
///
/// Estrutura simples: uma timeline única com TODOS os dias registados,
/// do mais recente para o mais antigo. Cada dia mostra as suas entradas
/// expandidas. Sem seletor de período (Dia/Semana/Mês/Ano) — o utilizador
/// queixou-se de só conseguir ver um dia de cada vez; agora vê tudo.
///
/// Funcionalidades:
///   * Pull-to-refresh força refetch do range carregado.
///   * Paginação automática ao chegar perto do fim do scroll (`loadMore`
///     no provider acrescenta mais 7 dias).
///   * FAB para adicionar nova refeição (data padrão = hoje).
///   * Toque num cabeçalho de dia → detalhe do dia.
///   * Toque numa entrada → editar refeição.
///
/// Para vistas agregadas / estatísticas / calendário usa `HistoryScreen`
/// (`/history`).
class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  final _scrollController = ScrollController();
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
    super.dispose();
  }

  /// Dispara `loadMore` quando o scroll chega a 200px do fim.
  /// Guard `_loadingMore` evita fetches sobrepostos.
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

  Future<void> _refresh() async {
    // setRange com o mesmo número de dias força um re-fetch sem alterar
    // a janela visível para o utilizador.
    final notifier = ref.read(nutritionLogsProvider.notifier);
    await notifier.setRange(notifier.daysLoaded);
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
          data: (logs) => RefreshIndicator(
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
                children: [
                  MealsTimeline(
                    logs: logs,
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
          ),
        ),
      ),
    );
  }
}
