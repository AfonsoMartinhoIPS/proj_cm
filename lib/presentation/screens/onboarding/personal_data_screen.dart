import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';

class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
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
              const Text('Olá! Vamos\nconhecer-te',
                  style: TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Precisamos de alguns dados para personalizar a tua experiência.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 30),
              _buildInputField(label: 'Nome completo', hint: 'Ana Ferreira'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Idade', hint: '26')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField(label: 'Sexo', hint: 'Feminino')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Peso (kg)', hint: '62')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField(label: 'Altura (cm)', hint: '168')),
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

  Widget _buildInputField({required String label, required String hint, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          TextField(
            style: const TextStyle(color: AppColors.onBackground, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.border),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stepIndicator(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}
