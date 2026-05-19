import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/presentation/widgets/nutri_back_button.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';

class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Center(child: NutriBackButton(onPressed: () => context.pop())),
        title: _stepIndicator('1 / 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Olá! Vamos\nconhecer-te',
                style: TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Precisamos de alguns dados para personalizar a tua experiência.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 30),
              const NutriTextField(
                label: 'Nome completo', 
                hint: 'Ana Ferreira',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: NutriTextField(label: 'Idade', hint: '26'),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: NutriTextField(label: 'Sexo', hint: 'Feminino'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: NutriTextField(label: 'Peso (kg)', hint: '62'),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: NutriTextField(label: 'Altura (cm)', hint: '168'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/onboarding/objectives'),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
      );
}