import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  DateTime? dateOfBirth;
  Gender gender = Gender.other;


  /**
   * Initialize the text controllers with existing onboarding data, if available. 
   * This allows users to go back and forth between steps without losing their input.
   */
  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    nameController.text = onboarding.name;
    weightController.text = onboarding.weight > 0 ? onboarding.weight.toString() : '';
    heightController.text = onboarding.height > 0 ? onboarding.height.toString() : '';
    dateOfBirth = onboarding.dateOfBirth;
    gender = onboarding.gender;
  }

  /**
   * Dispose of the text controllers when the widget is removed from the widget tree to free up resources.
   */
  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  /**
   * Show a date picker to allow the user to select their date of birth.
   */
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => dateOfBirth = picked);
  }

  void submit() {
    final name = nameController.text.trim();
    final weight = double.tryParse(weightController.text.trim());
    final height = int.tryParse(heightController.text.trim());

    if (name.isEmpty || dateOfBirth == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos')),
      );
      return;
    }

    ref.read(onboardingProvider.notifier).setPersonalData(
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const StepChip('1 / 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Olá! Vamos\nconhecer-te',
                  style: TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Precisamos de alguns dados para personalizar a tua experiência.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 30),
              NutriTextField(
                controller: nameController,
                label: 'Nome completo',
                hint: 'Ana Ferreira',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _dateField()),
                  const SizedBox(width: 15),
                  Expanded(child: _genderField()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: NutriTextField(controller: weightController, label: 'Peso (kg)', hint: '62', keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: NutriTextField(controller: heightController, label: 'Altura (cm)', hint: '168', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 40),
              NutriButton(label: 'Próximo', onPressed: submit),
              /*ElevatedButton(
                onPressed: submit,
                child: const Text('Próximo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),*/
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DATA DE NASCIMENTO',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              dateOfBirth == null
                  ? 'Selecionar'
                  : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
              style: TextStyle(
                color: dateOfBirth == null ? AppColors.border : AppColors.onBackground,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GENERO',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          DropdownButton<Gender>(
            value: gender,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.surfaceDark,
            style: const TextStyle(color: AppColors.onBackground, fontSize: 16),
            onChanged: (g) => setState(() => gender = g ?? Gender.other),
            items: const [
              DropdownMenuItem(value: Gender.female, child: Text('Feminino')),
              DropdownMenuItem(value: Gender.male,   child: Text('Masculino')),
              DropdownMenuItem(value: Gender.other,  child: Text('Outro')),
            ],
          ),
        ],
      ),
    );
  }

}
