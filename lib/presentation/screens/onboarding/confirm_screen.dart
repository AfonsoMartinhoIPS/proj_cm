import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Quarto e último passo do fluxo de onboarding — confirmação dos dados.
///
/// Exibe um resumo de todas as informações recolhidas nos passos anteriores
/// (dados pessoais, objetivos de peso e objetivos nutricionais) e permite
/// ao utilizador confirmar e criar a conta.
class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = ref.watch(onboardingProvider);

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
              const OnboardingStepIndicator(currentStep: 4, totalSteps: 4),
              const SizedBox(height: 30),
              NutriLabel(
                'Confirma os\nteus dados',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              NutriLabel(
                'Confirma os teus dados antes de criar a conta.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 30),
              NutriCard(
                variant: NutriCardVariant.surfaceDark,
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _dataRow('Nome', s.name.isEmpty ? '-' : s.name, colorScheme),
                    _dataRow('Idade', '${s.age} anos', colorScheme),
                    _dataRow('Sexo', _genderLabel(s.gender), colorScheme),
                    _dataRow('Altura', '${s.height} cm', colorScheme),
                    _dataRow('Peso', '${s.weight.toStringAsFixed(0)} kg', colorScheme),
                    _dataRow('Objectivo', s.objective?.label ?? '-', colorScheme),
                    if (s.nutritionGoals != null) ...[
                      _dataRow('Calorias', '${s.nutritionGoals!.calories.toStringAsFixed(0)} kcal', colorScheme),
                      _dataRow('Proteína', '${s.nutritionGoals!.protein.toStringAsFixed(0)} g', colorScheme),
                      _dataRow('Hidratos', '${s.nutritionGoals!.carbs.toStringAsFixed(0)} g', colorScheme),
                      _dataRow('Gordura', '${s.nutritionGoals!.fat.toStringAsFixed(0)} g', colorScheme),
                      _dataRow('Água', '${s.nutritionGoals!.water.toStringAsFixed(0)} ml', colorScheme),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              NutriButton(
                label: "Criar Conta",
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Converte um valor do enum [Gender] na sua representação textual em português.
  String _genderLabel(Gender g) => switch (g) {
    Gender.female => 'Feminino',
    Gender.male => 'Masculino',
    Gender.other => 'Outro',
  };

  /// Constrói uma linha de resumo com um rótulo e um valor.
  ///
  /// O [label] é apresentado à esquerda com a cor de texto secundária,
  /// e o [value] à direita em negrito.
  static Widget _dataRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NutriLabel(
            label,
            variant: NutriLabelVariant.body,
            color: colorScheme.onSurfaceVariant,
          ),
          NutriLabel(
            value,
            variant: NutriLabelVariant.body,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}