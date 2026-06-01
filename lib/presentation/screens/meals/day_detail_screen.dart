import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meal_entry_tile.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de detalhe de um dia específico de refeições.
///
/// Exibe o total diário de calorias e macronutrientes e agrupa as entradas
/// por tipo de refeição. Permite editar ou remover entradas individuais e
/// apagar o dia completo.
class DayDetailScreen extends ConsumerWidget {
  /// A data no formato YYYY-MM-DD a ser exibida.
  final String date;

  /// Cria um [DayDetailScreen].
  ///
  /// O parâmetro [date] é obrigatório.
  const DayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final logs = ref.watch(nutritionLogsProvider).value ?? [];
    final NutritionLog? log = logs.where((l) => l.date == date).firstOrNull;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: NutriTopNavBar(
        showBackButton: true,
        title: formatDmyFromIso(date),
        actions: [
          if (log != null && log.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Apagar dia',
              onPressed: () async {
                final ok = await showNutriConfirmDialog(
                  context,
                  title: 'Apagar dia?',
                  body:
                      'Vai remover todas as ${log.entries.length} '
                      'refeições registadas em ${formatDmyFromIso(date)}.',
                );
                if (!ok || !context.mounted) return;
                await ref.read(nutritionLogsProvider.notifier).deleteDay(date);
                if (!context.mounted) return;
                NutriFeedback.showInfo(context, 'Dia removido');
                context.pop();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: (log == null || log.entries.isEmpty)
            ? NutriEmptyState(
                icon: Icons.restaurant_outlined,
                title: 'Sem refeições registadas',
                actionLabel: '+ Adicionar refeição',
                onAction: () => context.push('/meals/add'),
              )
            : _Body(log: log),
      ),
    );
  }
}

/// Corpo do ecrã de detalhe do dia quando existem refeições.
///
/// Apresenta o card de totais, as secções de refeição agrupadas por
/// [MealType] e um botão para adicionar uma nova refeição.
class _Body extends ConsumerWidget {
  /// O registo de nutrição do dia.
  final NutritionLog log;

  /// Cria um [_Body].
  ///
  /// O parâmetro [log] é obrigatório.
  const _Body({required this.log});

  /// Agrupa as entradas do dia por tipo de refeição.
  ///
  /// Devolve um mapa em que cada chave é um [MealType] e o valor é a lista
  /// de entradas correspondentes.
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
                final ok = await showNutriConfirmDialog(
                  context,
                  title: 'Apagar refeição?',
                  body: 'Remover "${e.productName}" deste dia.',
                );
                if (!ok) return;
                await notifier.removeEntry(e.id, date: log.date);
                if (!context.mounted) return;
                NutriFeedback.showInfo(context, 'Refeição removida');
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

/// Card que apresenta o resumo total do dia.
///
/// Inclui as calorias totais e a distribuição dos macronutrientes (proteína,
/// hidratos e gordura), comparando cada valor com a meta definida.
class _DayTotalsCard extends StatelessWidget {
  /// O registo de nutrição do dia.
  final NutritionLog log;

  /// Cria um [_DayTotalsCard].
  ///
  /// O parâmetro [log] é obrigatório.
  const _DayTotalsCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final g = log.goals;
    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutriLabel(
            'TOTAL DO DIA',
            variant: NutriLabelVariant.small,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.sm),
          _MacroRow(
            label: 'Calorias',
            value: log.totalCalories,
            goal: g.calories.toDouble(),
            unit: 'kcal',
            color: colorScheme.secondary,
          ),
          _MacroRow(
            label: 'Proteína',
            value: log.totalProtein,
            goal: g.protein.toDouble(),
            unit: 'g',
            color: AppColors.protein,
          ),
          _MacroRow(
            label: 'Hidratos',
            value: log.totalCarbs,
            goal: g.carbs.toDouble(),
            unit: 'g',
            color: AppColors.carbs,
          ),
          _MacroRow(
            label: 'Gordura',
            value: log.totalFat,
            goal: g.fat.toDouble(),
            unit: 'g',
            color: AppColors.fat,
          ),
        ],
      ),
    );
  }
}

/// Linha de resumo para um macronutriente específico.
///
/// Apresenta o nome do nutriente, um pequeno círculo colorido, e os valores
/// atual e meta (ex.: "1200 / 1500 kcal").
class _MacroRow extends StatelessWidget {
  /// Nome do nutriente (ex.: "Calorias").
  final String label;

  /// Valor atual já consumido.
  final double value;

  /// Meta diária definida.
  final double goal;

  /// Unidade de medida (ex.: "kcal", "g").
  final String unit;

  /// Cor do círculo indicador.
  final Color color;

  /// Cria uma [_MacroRow].
  ///
  /// Todos os parâmetros são obrigatórios.
  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NutriLabel(
              label,
              variant: NutriLabelVariant.body,
              color: colorScheme.onSurface,
            ),
          ),
          NutriLabel(
            '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
            variant: NutriLabelVariant.small,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Secção que agrupa as entradas de um tipo de refeição.
///
/// Mostra o nome do tipo de refeição (ex.: "PEQUENO‑ALMOÇO"), o subtotal de
/// calorias desse grupo e a lista de [MealEntryTile] correspondentes.
class _MealTypeSection extends StatelessWidget {
  /// O tipo de refeição a que pertencem as entradas.
  final MealType type;

  /// A lista de entradas desse tipo de refeição.
  final List<MealEntry> entries;

  /// Callback invocado quando o utilizador quer editar uma entrada.
  final void Function(MealEntry) onEdit;

  /// Callback invocado quando o utilizador quer apagar uma entrada.
  final void Function(MealEntry) onDelete;

  /// Cria uma [_MealTypeSection].
  ///
  /// Todos os parâmetros são obrigatórios.
  const _MealTypeSection({
    required this.type,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtotal = entries.fold<double>(0, (s, e) => s + e.calories);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NutriCard(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.sm,
                right: AppSizes.sm,
                bottom: AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NutriLabel(
                    type.label.toUpperCase(),
                    variant: NutriLabelVariant.small,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  NutriLabel(
                    '${subtotal.toStringAsFixed(0)} kcal',
                    variant: NutriLabelVariant.small,
                    color: colorScheme.secondary,
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