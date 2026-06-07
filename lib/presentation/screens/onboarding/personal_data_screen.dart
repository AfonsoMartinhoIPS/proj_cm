import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

/// Primeiro passo do fluxo de onboarding — recolha de dados pessoais.
///
/// Pede ao utilizador o nome completo, data de nascimento, género, peso e
/// altura. Estes dados são guardados no [onboardingProvider] e servem de
/// base para o cálculo dos objetivos nutricionais nos passos seguintes.
class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

/// Estado do [PersonalDataScreen] que gere os campos de texto e a submissão.
class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  DateTime? dateOfBirth;
  Gender gender = Gender.other;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    nameController.text = onboarding.name;
    weightController.text = onboarding.weight > 0
        ? onboarding.weight.toString()
        : '';
    heightController.text = onboarding.height > 0
        ? onboarding.height.toString()
        : '';
    dateOfBirth = onboarding.dateOfBirth;
    gender = onboarding.gender;
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  /// Abre o seletor de data nativo para o utilizador escolher a data de
  /// nascimento.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => dateOfBirth = picked);
  }

  /// Valida os campos obrigatórios e avança para o próximo passo do
  /// onboarding.
  void submit() {
    final name = nameController.text.trim();
    final weight = double.tryParse(weightController.text.trim());
    final height = int.tryParse(heightController.text.trim());

    if (name.isEmpty ||
        dateOfBirth == null ||
        weight == null ||
        height == null) {
      NutriFeedback.showSnackBar(
        context,
        'Preenche todos os campos',
        NutriFeedbackType.error,
      );
      return;
    }

    ref
        .read(onboardingProvider.notifier)
        .setPersonalData(
          name: name,
          dateOfBirth: dateOfBirth!,
          gender: gender,
          weight: weight,
          height: height,
        );

    ref.read(onboardingProvider.notifier).calculateAndSetGoals();
    context.push('/onboarding/objectives');
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
              const OnboardingStepIndicator(currentStep: 1, totalSteps: 4),
              const SizedBox(height: 30),
              NutriLabel(
                'Olá! Vamos\nconhecer-te',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              NutriLabel(
                'Precisamos de alguns dados para personalizar a tua experiência.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 30),
              NutriTextField(
                controller: nameController,
                label: 'Nome completo',
                hint: 'ex. Ana Ferreira',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _dateField(colorScheme)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NutriLabel(
                          'GÉNERO',
                          variant: NutriLabelVariant.small,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8),
                        NutriChipSelector<Gender>(
                          items: Gender.values,
                          selected: gender,
                          onChanged: (g) => setState(() => gender = g),
                          label: (g) => g.label,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: NutriTextField(
                      controller: weightController,
                      label: 'Peso (kg)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: NutriTextField(
                      controller: heightController,
                      label: 'Altura (cm)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              NutriButton(label: 'Próximo', onPressed: submit),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Campo de data de nascimento estilizado.
  ///
  /// Exibe a data selecionada ou o texto "Selecionar" caso ainda não tenha
  /// sido escolhida. Ao ser tocado, abre o seletor de data nativo.
  Widget _dateField(ColorScheme colorScheme) {
    return InkWell(
      onTap: _pickDate,
      child: NutriCard(
        variant: NutriCardVariant.surfaceDark,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutriLabel(
              'DATA DE NASCIMENTO',
              variant: NutriLabelVariant.small,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 4),
            NutriLabel(
              dateOfBirth == null
                  ? 'Selecionar'
                  : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
              variant: NutriLabelVariant.body,
              color: dateOfBirth == null ? colorScheme.outline : null,
            ),
          ],
        ),
      ),
    );
  }
}