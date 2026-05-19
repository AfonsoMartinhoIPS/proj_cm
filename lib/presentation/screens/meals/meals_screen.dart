import 'package:flutter/material.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('21 Abr', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Hoje · 1 124 kcal consumidas',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMealCard(
                  title: 'Pequeno-almoço',
                  totalKcal: '342 kcal',
                  items: const [
                    {'name': 'Iogurte grego', 'kcal': '120 kcal'},
                    {'name': 'Granola', 'kcal': '180 kcal'},
                  ],
                ),
                _buildMealCard(
                  title: 'Almoço',
                  totalKcal: '480 kcal',
                  items: const [
                    {'name': 'Peito de frango', 'kcal': '220 kcal'},
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('+ Adicionar refeição'),
                ),
              ],
            ),
          ),
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
