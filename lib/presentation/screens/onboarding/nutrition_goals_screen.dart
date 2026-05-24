import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

class NutritionGoalsScreen extends ConsumerStatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  ConsumerState<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends ConsumerState<NutritionGoalsScreen> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // calculate defaults if not yet set, so fields prefill
    final notifier = ref.read(onboardingProvider.notifier);
    if (ref.read(onboardingProvider).nutritionGoals == null) {
      notifier.calculateAndSetGoals();
    }
    final goals = ref.read(onboardingProvider).nutritionGoals!;
    caloriesController.text = goals.calories.toStringAsFixed(0);
    proteinController.text  = goals.protein.toStringAsFixed(0);
    carbsController.text    = goals.carbs.toStringAsFixed(0);
    fatController.text      = goals.fat.toStringAsFixed(0);
    waterController.text    = goals.water.toStringAsFixed(0);
  }

  @override
  void dispose() {
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    waterController.dispose();
    super.dispose();
  }

  void submit() {
    final calories = double.tryParse(caloriesController.text.trim()) ?? 0;
    final protein  = double.tryParse(proteinController.text.trim())  ?? 0;
    final carbs    = double.tryParse(carbsController.text.trim())    ?? 0;
    final fat      = double.tryParse(fatController.text.trim())      ?? 0;
    final water    = double.tryParse(waterController.text.trim())    ?? 0;

    ref.read(onboardingProvider.notifier).setGoals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      water: water,
    );

    context.push('/onboarding/confirm');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: _stepIndicator('3 / 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Text('Os teus objetivos diários',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onBackground, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Calculados com base no teu perfil. Podes ajustar se quiseres.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    NutriTextField(controller: caloriesController, label: 'Calorias (kcal)', hint: '1580', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    NutriTextField(controller: proteinController, label: 'Proteína (g)', hint: '150', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    NutriTextField(controller: carbsController, label: 'Hidratos (g)', hint: '210', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    NutriTextField(controller: fatController, label: 'Gordura (g)', hint: '70', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    NutriTextField(controller: waterController, label: 'Água (ml)', hint: '2500', keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Próximo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _stepIndicator(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}
