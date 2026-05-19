import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';

// Localization tables. Dart's DateTime returns weekday/month as int;
// we map manually to avoid pulling in `intl` package for one screen.
const _ptWeekdays = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'];
const _ptWeekdaysShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
const _ptMonths = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

/// Format current date as "YYYY-MM-DD". Matches the Firestore doc id for NutritionLog.
String _todayKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Pretty header date in PT, e.g. "Segunda-feira, 7 Mai".
String _formatTodayHeader() {
  final now = DateTime.now();
  return '${_ptWeekdays[now.weekday - 1]}, ${now.day} ${_ptMonths[now.month - 1]}';
}

/// Home dashboard — shows today's intake, weekly bar chart, and today's meals.
/// All data comes from [nutritionLogsProvider] (list of recent logs) and [authProvider]
/// (current AppUser, for fallback goals).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(authProvider).value;
    final List<NutritionLog> nutritionLogs = ref.watch(nutritionLogsProvider).value ?? [];

    final todayKey = _todayKey();
    // Pick today's log out of the list. May be null if user hasn't logged anything yet.
    final NutritionLog? todayLog = nutritionLogs.cast<NutritionLog?>().firstWhere(
      (log) => log!.date == todayKey,
      orElse: () => null,
    );

    // Goals priority: log's snapshot (frozen on the day) → user's current goals → null.
    final NutritionGoals? goals = todayLog?.goals ?? user?.nutritionGoals;
    final double totalCalories = todayLog?.totalCalories ?? 0;
    final double totalProtein  = todayLog?.totalProtein  ?? 0;
    final double totalCarbs    = todayLog?.totalCarbs    ?? 0;
    final double totalFat      = todayLog?.totalFat      ?? 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Greeting(user: user),
            const SizedBox(height: 24),
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
                const Text('Esta semana',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => context.push('/history'),
                  child: const Text('Ver mais →', style: TextStyle(fontSize: 12)),
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
                const Text('Refeições de hoje',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.go('/meals'),
                  child: const Text('Ver todas', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            _TodayMeals(nutritionLog: todayLog),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Top row: greeting on the left, profile avatar (tappable) on the right.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${user?.displayName ?? "utilizador"}',
                style: const TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_formatTodayHeader(), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.person, color: AppColors.onBackground),
          ),
        ),
      ],
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
                  Text('Calorias hoje'.toUpperCase(),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(totalCalories.toStringAsFixed(0),
                      style: const TextStyle(color: AppColors.secondary, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('de ${goalCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
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
              _macro('Proteína', totalProtein, goals?.protein ?? 0, AppColors.secondary),
              _macro('Hidratos', totalCarbs,   goals?.carbs   ?? 0, AppColors.primary),
              _macro('Gordura',  totalFat,     goals?.fat     ?? 0, AppColors.onBackground),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macro(String label, double currentGrams, double goalGrams, Color color) {
    // Avoid divide-by-zero if goal not configured.
    final double progress = goalGrams > 0 ? (currentGrams / goalGrams).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
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
        Text('${currentGrams.toStringAsFixed(0)}/${goalGrams.toStringAsFixed(0)}g',
            style: const TextStyle(color: AppColors.onBackground, fontSize: 10, fontWeight: FontWeight.w500)),
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
    final List<DateTime> days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final String todayKey = _todayKey();

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final String dayKey =
              '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

          // Find the log for this day; null if user didn't log anything.
          final NutritionLog? dayLog = nutritionLogs.cast<NutritionLog?>().firstWhere(
            (log) => log!.date == dayKey,
            orElse: () => null,
          );
          final double dayCalories = dayLog?.totalCalories ?? 0;

          // Bar fraction (0.05 .. 1.0). Floor at 5% so zero-cal days still show a stub.
          final double barFraction = (dayCalories / (goalCalories * 1.2)).clamp(0.05, 1.0);
          final bool isToday = dayKey == todayKey;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 25,
                height: 60 * barFraction,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isToday ? AppColors.primary : Colors.white10),
                ),
              ),
              const SizedBox(height: 8),
              Text(_ptWeekdaysShort[day.weekday - 1],
                  style: TextStyle(
                    color: isToday ? AppColors.secondary : AppColors.textMuted,
                    fontSize: 10,
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// List of today's meals grouped by MealType (breakfast/lunch/dinner/snack).
/// Each row shows the meal name and total kcal for that meal.
class _TodayMeals extends StatelessWidget {
  const _TodayMeals({required this.nutritionLog});

  final NutritionLog? nutritionLog;

  static const Map<MealType, String> _mealLabels = {
    MealType.breakfast: 'Pequeno-almoço',
    MealType.lunch:     'Almoço',
    MealType.dinner:    'Jantar',
    MealType.snack:     'Snack',
  };

  @override
  Widget build(BuildContext context) {
    final List<MealEntry> entries = nutritionLog?.entries ?? const <MealEntry>[];
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Sem refeições registadas hoje.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      );
    }

    // Sum calories per meal type — multiple entries (e.g. two snacks) collapse to one row.
    final Map<MealType, double> caloriesByMealType = {};
    for (final entry in entries) {
      final double entryCalories = entry.nutriments.calories(grams: entry.servingGrams);
      caloriesByMealType[entry.mealType] = (caloriesByMealType[entry.mealType] ?? 0) + entryCalories;
    }

    return Column(
      // Iterate MealType.values to keep canonical order (breakfast → snack).
      children: MealType.values
          .where((mealType) => caloriesByMealType.containsKey(mealType))
          .map((mealType) => _mealRow(
                _mealLabels[mealType]!,
                '${caloriesByMealType[mealType]!.toStringAsFixed(0)} kcal',
              ))
          .toList(),
    );
  }

  Widget _mealRow(String title, String kcalLabel) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: const TextStyle(color: AppColors.onBackground, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(kcalLabel, style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
        ],
      ),
    );
  }
}
