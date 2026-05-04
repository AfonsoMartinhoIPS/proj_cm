import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bom dia, Ana',
                        style: TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Segunda-feira, 21 Abr', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
            ),
            const SizedBox(height: 24),
            _buildCalorieCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Esta semana',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver mais →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildWeeklyChart(),
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
            _buildMealItem('Pequeno-almoço', '342 kcal'),
            _buildMealItem('Almoço', '480 kcal'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
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
                  const Text('1 124',
                      style: TextStyle(color: AppColors.secondary, fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text('de 1 580 kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Text('71%',
                    style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.71,
              backgroundColor: AppColors.surfaceDark,
              color: AppColors.secondary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo('Proteína', '100/125g', 0.8, AppColors.secondary),
              _buildMacroInfo('Hidratos', '105/175g', 0.6, AppColors.primary),
              _buildMacroInfo('Gordura', '23/52g', 0.4, AppColors.onBackground),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, double progress, Color color) {
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
        Text(value, style: const TextStyle(color: AppColors.onBackground, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMealItem(String title, String kcal) {
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
          Text(kcal, style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final heights = [0.6, 0.8, 0.5, 0.9, 0.7, 0.2, 0.2];

    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isToday = i == 4;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 25,
                height: 50 * heights[i],
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isToday ? AppColors.primary : Colors.white10),
                ),
              ),
              const SizedBox(height: 8),
              Text(days[i],
                  style: TextStyle(
                    color: isToday ? AppColors.secondary : AppColors.textMuted,
                    fontSize: 10,
                  )),
            ],
          );
        }),
      ),
    );
  }
}
