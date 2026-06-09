import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Segundo passo do fluxo de onboarding — definição de objetivos.
///
/// Permite ao utilizador selecionar um objetivo principal relacionado com o
/// peso (perder, manter ou ganhar) e, opcionalmente, objetivos secundários
/// como melhorar o desempenho desportivo ou criar hábitos saudáveis.
class ObjectivesScreen extends ConsumerStatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  ConsumerState<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

/// Estado do [ObjectivesScreen] que gere a seleção de objetivos e a navegação.
class _ObjectivesScreenState extends ConsumerState<ObjectivesScreen> {
  /// Objetivo principal selecionado (relacionado com o peso).
  Objective _selectedObjective = Objective.loseWeight;

  /// Lista de objetivos secundários que o utilizador selecionou.
  final List<String> _selectedSecondaryObjectives = [
    'Melhorar desempenho desportivo',
  ];

  /// Opções disponíveis para os objetivos secundários.
  final List<String> _otherObjectivesOptions = [
    'Melhorar desempenho desportivo',
    'Criar hábitos mais saudáveis',
    'Prevenir doenças relacionadas ao estilo de vida',
  ];

  /// Define o objetivo principal e atualiza a interface.
  void _selectObjective(Objective objective) {
    setState(() {
      _selectedObjective = objective;
    });
  }

  /// Adiciona ou remove um objetivo secundário da lista de selecionados.
  void _toggleSecondaryObjective(String option) {
    setState(() {
      if (_selectedSecondaryObjectives.contains(option)) {
        _selectedSecondaryObjectives.remove(option);
      } else {
        _selectedSecondaryObjectives.add(option);
      }
    });
  }

  /// Guarda o objetivo principal no [onboardingProvider] e avança para o
  /// passo seguinte (objetivos nutricionais).
  void submit() {
    ref.read(onboardingProvider.notifier).setObjective(_selectedObjective);
    context.push('/onboarding/nutrition-goals');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const OnboardingStepIndicator(currentStep: 2, totalSteps: 4),
              const SizedBox(height: 30),
              NutriLabel(
                'Quais os teus\nobjetivos?',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              NutriLabel(
                'Usamos estas informações para elaborar recomendações personalizadas.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 30),
              NutriLabel(
                'PESO',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              _buildWeightSelector(colorScheme),
              const SizedBox(height: 30),
              NutriLabel(
                'OUTROS',
                variant: NutriLabelVariant.small,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              ..._otherObjectivesOptions.map((option) {
                final isSelected =
                    _selectedSecondaryObjectives.contains(option);
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

  /// Constrói o seletor visual do objetivo de peso.
  ///
  /// Exibe as opções [Objective.loseWeight], [Objective.maintainWeight] e
  /// [Objective.gainWeight] lado a lado dentro de um [NutriCard], destacando
  /// a opção atualmente selecionada com a cor primária do tema.
  Widget _buildWeightSelector(ColorScheme colorScheme) {
    return NutriCard(
      variant: NutriCardVariant.surfaceDark,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: Objective.values.map((option) {
          final selected = _selectedObjective == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectObjective(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: NutriLabel(
                  option.label,
                  variant: NutriLabelVariant.small,
                  textAlign: TextAlign.center,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}