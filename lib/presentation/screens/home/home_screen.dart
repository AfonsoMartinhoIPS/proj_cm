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
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Home dashboard - shows today's intake, weekly bar chart, and today's meals.
/// All data comes from [nutritionLogsProvider] (list of recent logs) and [authProvider]
/// (current AppUser, for fallback goals).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(authProvider).value;
    final List<NutritionLog> nutritionLogs =
        ref.watch(nutritionLogsProvider).value ?? [];

    final today = todayKey();
    // Pick today's log out of the list. May be null if user hasn't logged anything yet.
    final NutritionLog? todayLog = nutritionLogs
        .cast<NutritionLog?>()
        .firstWhere((log) => log!.date == today, orElse: () => null);

    // Goals priority: log's snapshot (frozen on the day) → user's current goals → null.
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
              color: AppColors.onBackground,
            ),
            const SizedBox(height: 2),
            NutriLabel(
              formatPtHeader(DateTime.now()),
              variant: NutriLabelVariant.small,
              color: AppColors.textMuted,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // TODO: replace with NutriCard widget
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.person, color: AppColors.onBackground),
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
                const NutriLabel(
                  'Esta semana',
                  variant: NutriLabelVariant.body,
                  color: AppColors.textMuted,
                ),
                NutriButton.text(
                  label: 'Ver mais →',
                  onPressed: () => context.push('/history'),
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
                const NutriLabel(
                  'Refeições de hoje',
                  variant: NutriLabelVariant.body,
                  color: AppColors.textMuted,
                ),

                NutriButton.text(
                  label: 'Ver todas',
                  onPressed: () => context.go('/meals'),
                ),
              ],
            ),
            _TodayMeals(nutritionLog: todayLog),
            const SizedBox(height: 20),
          ],
        ),
      ),
    )
    );
  }
}

/// Main card: shows today's total calories vs daily goal, with progress bar
/// and macro breakdown (protein / carbs / fat).
class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.goals,
  });

  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final NutritionGoals? goals;

  @override
  Widget build(BuildContext context) {
    final double goalCalories = goals?.calories ?? 2000;
    // Clamp prevents progress bar from overflowing 100% if user exceeds goal.
    final double progress = (totalCalories / goalCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
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
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 4),
                  NutriLabel.rich(
                    variant: NutriLabelVariant.headline,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: totalCalories.toStringAsFixed(0),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '\n de ${goalCalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            color: AppColors.textMuted,
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: NutriLabel(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  variant: NutriLabelVariant.small,
                  color: Colors.white,
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
              backgroundColor: AppColors.surfaceDark,
              color: AppColors.secondary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macro(
                'Proteína',
                totalProtein,
                goals?.protein ?? 0,
                AppColors.secondary,
              ),
              _macro(
                'Hidratos',
                totalCarbs,
                goals?.carbs ?? 0,
                AppColors.primary,
              ),
              _macro(
                'Gordura',
                totalFat,
                goals?.fat ?? 0,
                AppColors.onBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macro(
    String label,
    double currentGrams,
    double goalGrams,
    Color color,
  ) {
    // Avoid divide-by-zero if goal not configured.
    final double progress = goalGrams > 0
        ? (currentGrams / goalGrams).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NutriLabel(
          label.toUpperCase(),
          variant: NutriLabelVariant.small,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceDark,
              color: color,
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        NutriLabel(
          '${currentGrams.toStringAsFixed(0)}g / ${goalGrams.toStringAsFixed(0)}g',
          variant: NutriLabelVariant.small,
          color: AppColors.textMuted,
        ),
      ],
    );
  }
}

/// Last-7-days bar chart of total calories per day.
/// Bar height is scaled relative to (goal * 1.2) so a day at goal hits ~83%,
/// leaving headroom for over-goal days without flattening normal days at 100%.
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.nutritionLogs, required this.goalCalories});

  final List<NutritionLog> nutritionLogs;
  final double goalCalories;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Build the 7 days, oldest first → today last, so the chart reads left-to-right.
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

          // Find the log for this day; null if user didn't log anything.
          final NutritionLog? dayLog = nutritionLogs
              .cast<NutritionLog?>()
              .firstWhere((log) => log!.date == dayKey, orElse: () => null);
          final double dayCalories = dayLog?.totalCalories ?? 0;

          // Bar fraction (0.05 .. 1.0). Floor at 5% so zero-cal days still show a stub.
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
                  color: isToday ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isToday ? AppColors.primary : Colors.white10,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              NutriLabel(
                ptWeekdaysShort[day.weekday - 1],
                variant: NutriLabelVariant.small,
                color: isToday ? AppColors.secondary : AppColors.textMuted,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Today's entries grouped by [MealType]. Each section shows its subtotal
/// kcal; entries render via [MealEntryTile]. Tapping a tile opens the day
/// detail screen so the user can edit/delete from there (no inline mutation
/// on the home screen - keeps this widget read-only).
class _TodayMeals extends ConsumerWidget {
  const _TodayMeals({required this.nutritionLog});

  final NutritionLog? nutritionLog;

  static const _mealLabels = {
    MealType.breakfast: 'Pequeno-almoço',
    MealType.lunch: 'Almoço',
    MealType.dinner: 'Jantar',
    MealType.snack: 'Snack',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MealEntry> entries =
        nutritionLog?.entries ?? const <MealEntry>[];
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: NutriLabel(
          'Sem refeições registadas hoje.',
          variant: NutriLabelVariant.small,
          color: AppColors.textMuted,
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

class _MealTypeBlock extends StatelessWidget {
  final String label;
  final List<MealEntry> entries;
  final VoidCallback onTap;

  const _MealTypeBlock({
    required this.label,
    required this.entries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = entries.fold<double>(0, (s, e) => s + e.calories);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm, vertical: AppSizes.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutriLabel(
                  label.toUpperCase(),
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
          // Read-only on home: tap → day detail. We pass the same `onTap` for
          // both edit + delete so the user is routed to detail instead of
          // mutating from here.
          for (final e in entries)
            MealEntryTile(
              entry: e,
              onEdit: onTap,
              onDelete: onTap,
            ),
        ],
      ),
    );
  }
}
