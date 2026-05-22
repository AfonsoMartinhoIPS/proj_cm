import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NutriTopNavBar(
        showBackButton: true,
        title: '4 / 4',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const NutriLabel(
                'Confirma os\nteus dados',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              const NutriLabel(
                'Confirma os teus dados antes de criar a conta.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _dataRow('Nome', s.name.isEmpty ? '—' : s.name),
                    _dataRow('Idade', '${s.age} anos'),
                    _dataRow('Sexo', _genderLabel(s.gender)),
                    _dataRow('Altura', '${s.height} cm'),
                    _dataRow('Peso', '${s.weight.toStringAsFixed(0)} kg'),
                    _dataRow('Objectivo', s.objective?.label ?? '—'),
                    if (s.nutritionGoals != null) ...[
                      _dataRow(
                        'Calorias',
                        '${s.nutritionGoals!.calories.toStringAsFixed(0)} kcal',
                      ),
                      _dataRow(
                        'Proteína',
                        '${s.nutritionGoals!.protein.toStringAsFixed(0)} g',
                      ),
                      _dataRow(
                        'Hidratos',
                        '${s.nutritionGoals!.carbs.toStringAsFixed(0)} g',
                      ),
                      _dataRow(
                        'Gordura',
                        '${s.nutritionGoals!.fat.toStringAsFixed(0)} g',
                      ),
                      _dataRow(
                        'Água',
                        '${s.nutritionGoals!.water.toStringAsFixed(0)} ml',
                      ),
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

  String _genderLabel(Gender g) => switch (g) {
    Gender.female => 'Feminino',
    Gender.male => 'Masculino',
    Gender.other => 'Outro',
  };

  static Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NutriLabel(
            label,
            variant: NutriLabelVariant.body,
            color: AppColors.textMuted,
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

  static Widget _stepIndicator(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: NutriLabel( //TODO: ver o estado visual
      label,
        color: AppColors.secondary,
        variant: NutriLabelVariant.small,
        fontWeight: FontWeight.bold,
    ),
  );
}
