import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/utils/meal_utils.dart';

import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {

  @override
  Widget build(BuildContext context) {

    final List<NutritionLog> nutritionLogs = ref.watch(nutritionLogsProvider).value ?? [];
    SavedProduct? savedProduct = ref.watch(savedProductsProvider).value?.firstOrNull;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                NutriLabel(
                  'Refeições', variant: NutriLabelVariant.display,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Parse nutrition logs into meal cards
                ...nutritionLogs.map((log) => _buildMealCard(
                  title: log.date,
                  totalKcal: '${log.totalCalories} kcal',
                  items: log.entries.map((e) => {'name': e.productName, 'kcal': '${calculateCaloriesFromMealEntry(e)} kcal'}).toList(),
                )),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {context.push('/meals/add');},
                  child: 
                  const NutriLabel(
                    '+ Adicionar refeição',
                    variant: NutriLabelVariant.body,
                  ),
                ),
              ]
            ),
            )
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String totalKcal,
    required List<Map<String, String>> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceDark.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutriLabel(title, variant: NutriLabelVariant.bodyLarge),
                NutriLabel(totalKcal, variant: NutriLabelVariant.body, color: AppColors.secondary),
              ],
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutriLabel(item['name']!, variant: NutriLabelVariant.small, color: AppColors.onBackground),
                NutriLabel(
                  item['kcal']!,
                  variant: NutriLabelVariant.small,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
