// lib/presentation/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/history/history_helpers.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meals_timeline.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de histórico de nutrição.
///
/// Estrutura:
///   1. Chips de intervalo (7d / 30d / 90d) que accionam `setRange` no provider.
///   2. Cartão de estatísticas com média de kcal/dia, dias com registos, total de refeições.
///   3. Lista do mais recente para o mais antigo com [MealsTimeline] (dias vazios são filtrados).
///
/// Tocar num dia abre o [DayDetailScreen] via `/meals/day/:date`.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

/// Os três intervalos predefinidos expostos no seletor de chips.
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
  final _scrollController = ScrollController();
  _Range _range = _Range.week;

  @override
  void initState() {
    super.initState();
    // Sincroniza o intervalo do provider com o estado inicial do ecrã.
    // O provider mantém a janela entre navegações (para que o ecrã de
    // refeições e a página inicial vejam os mesmos dados), mas os
    // utilizadores do histórico geralmente esperam um intervalo novo ao entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setRange(_range, refetch: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Define o intervalo selecionado e opcionalmente recarrega os dados.
  void _setRange(_Range r, {bool refetch = true}) {
    setState(() => _range = r);
    if (refetch) {
      ref.read(nutritionLogsProvider.notifier).setRange(r.days);
    }
  }

  /// Força a actualização dos dados mantendo o intervalo actual.
  Future<void> _refresh() async {
    final notifier = ref.read(nutritionLogsProvider.notifier);
    await notifier.setRange(notifier.daysLoaded);
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
            // Filtra os logs de acordo com o intervalo selecionado
            final filtered = filterLogs(logs, daysBack: _range.days);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Seletor de intervalo (7 dias / 30 dias / 90 dias)
                  _RangePicker(
                    selected: _range,
                    onChanged: (r) => _setRange(r),
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Cartão com estatísticas do período
                  _StatsRow(logs: filtered, totalDays: _range.days),
                  const SizedBox(height: AppSizes.md),
                  // Lista de refeições ou estado vazio
                  if (filtered.isEmpty)
                    const _EmptyState()
                  else
                    MealsTimeline(
                      logs: filtered,
                      onDayTap: (log) =>
                          context.push('/meals/day/${log.date}'),
                      onDayDelete: (log) =>
                          confirmDeleteDay(context, log, ref),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Seletor de intervalo de tempo com chips.
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

/// Três cartões de estatísticas em linha: média de kcal/dia nos dias com
/// registos, adesão (dias registados / total de dias no período), total de
/// refeições registadas.
///
/// A média utiliza apenas os dias que têm entradas — dias sem entradas
/// distorceriam a média para 0 e representariam mal a ingestão típica.
class _StatsRow extends StatelessWidget {
  final List<NutritionLog> logs;
  final int totalDays;

  const _StatsRow({required this.logs, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    // Considera apenas os dias que têm pelo menos uma refeição
    final withEntries = logs.where((l) => l.entries.isNotEmpty).toList();
    final loggedDays = withEntries.length;
    final totalEntries =
        withEntries.fold<int>(0, (s, l) => s + l.entries.length);
    final avgKcal = loggedDays == 0
        ? 0
        : withEntries.fold<double>(0, (s, l) => s + l.totalCalories) /
            loggedDays;

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

/// Estado vazio apresentado quando não existem refeições no período.
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