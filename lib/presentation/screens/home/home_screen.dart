// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/meal_entry_tile.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Painel principal (home) da aplicação.
///
/// Exibe o resumo de calorias do dia atual, um gráfico semanal de ingestão
/// e a lista de refeições de hoje agrupadas por tipo.
/// Os dados provêm do [nutritionLogsProvider] e do [authProvider].
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final AppUser? user = ref.watch(authProvider).value;
    final List<NutritionLog> nutritionLogs =
        ref.watch(nutritionLogsProvider).value ?? [];

    final today = todayKey();
    final NutritionLog? todayLog = nutritionLogs
        .cast<NutritionLog?>()
        .firstWhere((log) => log!.date == today, orElse: () => null);

    final NutritionGoals? goals = todayLog?.goals ?? user?.nutritionGoals;
    final double totalCalories = todayLog?.totalCalories ?? 0;
    final double totalProtein = todayLog?.totalProtein ?? 0;
    final double totalCarbs = todayLog?.totalCarbs ?? 0;
    final double totalFat = todayLog?.totalFat ?? 0;

    return Scaffold(
      appBar: NutriTopNavBar(
        showBackButton: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            NutriLabel(
              'Olá, ${user?.displayName ?? "utilizador"}',
              variant: NutriLabelVariant.headline,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 2),
            NutriLabel(
              formatPtHeader(DateTime.now()),
              variant: NutriLabelVariant.small,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: SizedBox(
                width: 40,
                height: 40,
                child: NutriCard(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(40),
                  child: Center(
                    child: Icon(Icons.person, color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalorieCard(
                totalCalories: totalCalories,
                totalProtein: totalProtein,
                totalCarbs: totalCarbs,
                totalFat: totalFat,
                goals: goals,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NutriLabel(
                    'Esta semana',
                    variant: NutriLabelVariant.body,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  NutriButton.text(
                    label: 'Ver mais →',
                    onPressed: () => context.go('/meals'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _WeeklyChart(
                nutritionLogs: nutritionLogs,
                goalCalories: goals?.calories ?? 2000,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NutriLabel(
                    'Refeições de hoje',
                    variant: NutriLabelVariant.body,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  NutriButton.text(
                    label: 'Ver todas',
                    onPressed: () => context.go('/meals?mode=day'),
                  ),
                ],
              ),
              _TodayMeals(nutritionLog: todayLog),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão principal com o resumo calórico do dia.
///
/// Mostra as calorias totais em relação à meta diária, uma barra de progresso
/// e a distribuição dos três macronutrientes (proteína, hidratos, gordura).
class _CalorieCard extends StatelessWidget {
  /// Calorias totais consumidas hoje.
  final double totalCalories;

  /// Proteína total consumida hoje (em gramas).
  final double totalProtein;

  /// Hidratos de carbono totais consumidos hoje (em gramas).
  final double totalCarbs;

  /// Gordura total consumida hoje (em gramas).
  final double totalFat;

  /// Metas nutricionais do utilizador. Pode ser `null`.
  final NutritionGoals? goals;

  const _CalorieCard({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double goalCalories = goals?.calories ?? 2000;
    final double progress = (totalCalories / goalCalories).clamp(0.0, 1.0);

    return NutriCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    'Calorias hoje'.toUpperCase(),
                    variant: NutriLabelVariant.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  NutriLabel.rich(
                    variant: NutriLabelVariant.headline,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: totalCalories.toStringAsFixed(0),
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '\n de ${goalCalories.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: NutriLabel(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  variant: NutriLabelVariant.small,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.secondary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: NutriNutrientProgressBar(
                  label: 'Proteína',
                  current: totalProtein,
                  goal: (goals?.protein ?? 0).toDouble(),
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NutriNutrientProgressBar(
                  label: 'Hidratos',
                  current: totalCarbs,
                  goal: (goals?.carbs ?? 0).toDouble(),
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NutriNutrientProgressBar(
                  label: 'Gordura',
                  current: totalFat,
                  goal: (goals?.fat ?? 0).toDouble(),
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gráfico de barras dos últimos 7 dias.
///
/// Cada barra representa as calorias totais de um dia, dimensionadas
/// relativamente à meta diária multiplicada por 1,2 (para dar margem a dias
/// acima da meta). O dia atual é destacado com a cor primária.
class _WeeklyChart extends StatelessWidget {
  /// Lista de registos de nutrição dos últimos dias.
  final List<NutritionLog> nutritionLogs;

  /// Meta calórica diária de referência.
  final double goalCalories;

  const _WeeklyChart({required this.nutritionLogs, required this.goalCalories});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final List<DateTime> days = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );
    final String today = todayKey();

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final String dayKey = dateKey(day);
          final NutritionLog? dayLog = nutritionLogs
              .cast<NutritionLog?>()
              .firstWhere((log) => log!.date == dayKey, orElse: () => null);
          final double dayCalories = dayLog?.totalCalories ?? 0;
          final double barFraction = (dayCalories / (goalCalories * 1.2)).clamp(
            0.05,
            1.0,
          );
          final bool isToday = dayKey == today;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 25,
                height: 60 * barFraction,
                decoration: BoxDecoration(
                  color: isToday ? colorScheme.primary : colorScheme.secondary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isToday ? colorScheme.primary : colorScheme.outline,
                    width: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              NutriLabel(
                ptWeekdaysShort[day.weekday - 1],
                variant: NutriLabelVariant.small,
                color: isToday
                    ? colorScheme.secondary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Lista das refeições de hoje agrupadas por tipo de refeição.
///
/// Se não existirem refeições registadas, exibe uma mensagem informativa.
class _TodayMeals extends ConsumerWidget {
  /// O registo de nutrição do dia de hoje. Pode ser `null`.
  final NutritionLog? nutritionLog;

  const _TodayMeals({required this.nutritionLog});

  static const _mealLabels = {
    MealType.breakfast: 'Pequeno-almoço',
    MealType.lunch: 'Almoço',
    MealType.dinner: 'Jantar',
    MealType.snack: 'Snack',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<MealEntry> entries =
        nutritionLog?.entries ?? const <MealEntry>[];
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: NutriLabel(
          'Sem refeições registadas hoje.',
          variant: NutriLabelVariant.small,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final grouped = <MealType, List<MealEntry>>{
      for (final t in MealType.values) t: [],
    };
    for (final e in entries) {
      grouped[e.mealType]!.add(e);
    }
    final date = nutritionLog!.date;

    return Column(
      children: [
        for (final type in MealType.values)
          if (grouped[type]!.isNotEmpty)
            _MealTypeBlock(
              label: _mealLabels[type]!,
              entries: grouped[type]!,
              onTap: () => context.push('/meals/day/$date'),
            ),
      ],
    );
  }
}

/// Bloco que representa um tipo de refeição (ex.: Pequeno‑almoço).
///
/// Mostra o nome do tipo de refeição, o subtotal de calorias e a lista das
/// entradas correspondentes. O toque em qualquer entrada redireciona para o
/// detalhe do dia (leitura apenas — as ações de editar/apagar são feitas lá).
class _MealTypeBlock extends StatelessWidget {
  /// Nome do tipo de refeição (ex.: "Pequeno-almoço").
  final String label;

  /// Lista de entradas desse tipo de refeição.
  final List<MealEntry> entries;

  /// Callback executado ao tocar numa entrada (abre o detalhe do dia).
  final VoidCallback onTap;

  const _MealTypeBlock({
    required this.label,
    required this.entries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtotal = entries.fold<double>(0, (s, e) => s + e.calories);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutriLabel(
                  label.toUpperCase(),
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
            MealEntryTile(entry: e, onEdit: onTap, onDelete: onTap),
        ],
      ),
    );
  }
}