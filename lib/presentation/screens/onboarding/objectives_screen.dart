// lib/presentation/screens/on_boarding/objectives_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class ObjectivesScreen extends ConsumerStatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  ConsumerState<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends ConsumerState<ObjectivesScreen> {
  Objective _selectedObjective = Objective.loseWeight;

  final List<String> _selectedSecondaryObjectives = [
    'Melhorar desempenho desportivo',
  ];

  // Lista com as opções disponíveis para o Toggler
  final List<String> _otherObjectivesOptions = [
    'Melhorar desempenho desportivo',
    'Criar hábitos mais saudáveis',
    'Prevenir doenças relacionadas ao estilo de vida',
  ];

  void _selectObjective(Objective objective) {
    setState(() {
      _selectedObjective = objective;
    });
  }

  void _toggleSecondaryObjective(String option) {
    setState(() {
      if (_selectedSecondaryObjectives.contains(option)) {
        _selectedSecondaryObjectives.remove(option);
      } else {
        _selectedSecondaryObjectives.add(option);
      }
    });
  }

  void submit() {
    ref.read(onboardingProvider.notifier).setObjective(_selectedObjective);
    //TODO: Guardar objetivo secondario:
    //ref.read(onboardingProvider.notifier).setSecondaryObjectives(_selectedSecondaryObjectives);

    context.push('/onboarding/nutrition-goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NutriTopNavBar(
        showBackButton: true,
        title: '2 / 4',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const NutriLabel(
                'Quais os teus\nobjetivos?',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              const NutriLabel(
                'Usamos estas informações para elaborar recomendações personalizadas.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 30),
              const NutriLabel(
                'PESO',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              _buildWeightSelector(),
              const SizedBox(height: 30),
              const NutriLabel(
                'OUTROS',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              ..._otherObjectivesOptions.map((option) {
                final isSelected = _selectedSecondaryObjectives.contains(
                  option,
                );
                return NutriToggler(
                  title: option,
                  isSelected: isSelected,
                  onTap: () => _toggleSecondaryObjective(option),
                );
              }),
              const SizedBox(height: 40),
              NutriButton(label: 'Próximo', onPressed: submit),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSelector() {
    return Container(
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: Objective.values.map((option) {
          final selected = _selectedObjective == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectObjective(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: NutriLabel(
                  option.label,
                  variant: NutriLabelVariant.small,
                  textAlign: TextAlign.center,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? AppColors.onBackground
                      : AppColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
