import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) context.go('/onboarding/nutrition-goals');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 2),
                    ),
                  ),
                  const Text('📊', style: TextStyle(fontSize: 60)),
                  const SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text('A calcular o teu plano...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onBackground, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text(
                'Estamos a analisar os teus dados para criar metas de calorias e macros ideais para ti.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 50),
              _buildStep('Analisar perfil biométrico', isDone: true),
              _buildStep('Ajustar metas de peso', isDone: true),
              _buildStep('Finalizar recomendações', isDone: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String title, {required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.secondary : AppColors.border,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                color: isDone ? AppColors.onBackground : AppColors.textMuted,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
