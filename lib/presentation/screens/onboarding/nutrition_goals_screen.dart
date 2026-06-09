import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

/// Terceiro passo do fluxo de onboarding — definição dos objetivos nutricionais.
///
/// Apresenta campos para o utilizador ajustar as calorias diárias e a
/// distribuição de macronutrientes (proteínas, hidratos, gordura) e água.
/// Os valores são pré‑preenchidos com base no perfil introduzido nos passos
/// anteriores e podem ser alterados livremente.
class NutritionGoalsScreen extends ConsumerStatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  ConsumerState<NutritionGoalsScreen> createState() =>
      _NutritionGoalsScreenState();
}

/// Estado do [NutritionGoalsScreen] que gere os campos de texto e a submissão.
class _NutritionGoalsScreenState extends ConsumerState<NutritionGoalsScreen> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(onboardingProvider.notifier);
    if (ref.read(onboardingProvider).nutritionGoals == null) {
      notifier.calculateAndSetGoals();
    }
    final goals = ref.read(onboardingProvider).nutritionGoals!;
    caloriesController.text = goals.calories.toStringAsFixed(0);
    proteinController.text = goals.protein.toStringAsFixed(0);
    carbsController.text = goals.carbs.toStringAsFixed(0);
    fatController.text = goals.fat.toStringAsFixed(0);
    waterController.text = goals.water.toStringAsFixed(0);
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

  /// Guarda os valores introduzidos no [onboardingProvider] e avança para a
  /// confirmação final.
  void submit() {
    final calories = double.tryParse(caloriesController.text.trim()) ?? 0;
    final protein = double.tryParse(proteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
    final fat = double.tryParse(fatController.text.trim()) ?? 0;
    final water = double.tryParse(waterController.text.trim()) ?? 0;

    ref
        .read(onboardingProvider.notifier)
        .setGoals(
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const OnboardingStepIndicator(currentStep: 3, totalSteps: 4),
              const SizedBox(height: 30),
              NutriLabel(
                'Os teus objetivos diários',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 12),
              NutriLabel(
                'Calculados com base no teu perfil. Podes ajustar se quiseres.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 40),
              NutriCard(
                variant: NutriCardVariant.surfaceDark,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                borderRadius: BorderRadius.circular(25),
                child: Column(
                  children: [
                    NutriTextField(
                      controller: caloriesController,
                      label: 'Calorias (kcal)',
                      hint: 'ex. 1580',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    NutriTextField(
                      controller: proteinController,
                      label: 'Proteína (g)',
                      hint: 'ex. 150',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    NutriTextField(
                      controller: carbsController,
                      label: 'Hidratos (g)',
                      hint: 'ex. 210',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    NutriTextField(
                      controller: fatController,
                      label: 'Gordura (g)',
                      hint: 'ex. 70',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    NutriTextField(
                      controller: waterController,
                      label: 'Água (ml)',
                      hint: 'ex. 2500',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              NutriButton(label: 'Próximo', onPressed: submit, fontSize: 16),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}