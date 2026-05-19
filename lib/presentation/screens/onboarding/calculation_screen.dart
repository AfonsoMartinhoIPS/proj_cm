import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';

import 'package:projeto/presentation/widgets/app_step_indicator.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) context.go('/onboarding/estimate');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                    decoration: BoxDecoration( // TODO: Consider creating a reusable CircularProgressContainer widget
                    //Para fazer este widget, é preciso fazer "checkpoints" nos calculos, para ir atualizando o progresso. Por exemplo: 1 checkpoint para análise de dados, outro para ajuste de metas, etc. Assim, o progresso pode ser atualizado dinamicamente com base no número de checkpoints concluídos.
                      shape: BoxShape.circle, // This is a custom circular container, not a standard progress indicator.
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 2),
                    ), // This is a custom circular container, not a standard progress indicator.
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
              Text('A calcular o teu plano...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge), // Removed const
              const SizedBox(height: 15),
              Text(
                'Estamos a analisar os teus dados para criar metas de calorias e macros ideais para ti.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, height: 1.5)),
              const SizedBox(height: 50),
              const AppStepIndicator(title: 'Analisar perfil biométrico', isDone: true),
              const AppStepIndicator(title: 'Ajustar metas de peso', isDone: true),
              const AppStepIndicator(title: 'Finalizar recomendações', isDone: false),
            ],
          ),
        ),
      ),
    );
  }

}
