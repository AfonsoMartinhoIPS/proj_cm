import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';

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
                Text('Refeições',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 22, fontWeight: FontWeight.bold)),
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
                  items: log.entries.map((e) => {'name': e.productName, 'kcal': '${e.totalCalories.toStringAsFixed(0)} kcal'}).toList(),
                )),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {context.push('/meals/add');},
                  child: const Text('+ Adicionar refeição'),
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
                Text(title,
                    style: const TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
                Text(totalKcal, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
              ],
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['name']!,
                    style: const TextStyle(color: AppColors.onBackground, fontSize: 13)),
                Text(item['kcal']!,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
