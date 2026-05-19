import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: _stepIndicator('4 / 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Confirma os\nteus dados',
                  style: TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Confirma os teus dados antes de criar a conta.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
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
                    _dataRow('Nome', 'Ana Ferreira'),
                    _dataRow('Idade', '26 anos'),
                    _dataRow('Sexo', 'Feminino'),
                    _dataRow('Altura', '168 cm'),
                    _dataRow('Objectivo', 'Perder Peso'),
                    _dataRow('Calorias', '1580 kcal'),
                    _dataRow('Atividade', 'Sedentário/a'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/register'),
                child: const Text('Criar Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/onboarding/personal-data'),
                child: const Text('Editar dados', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.onBackground, fontSize: 14, fontWeight: FontWeight.bold)),
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
