import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de transição exibido durante o cálculo do plano nutricional.
///
/// Mostra uma animação de carregamento e uma lista de passos que estão a ser
/// executados. Após alguns segundos, navega automaticamente para o ecrã de
/// objetivos nutricionais.
class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

/// Estado do [CalculationScreen] que gere o temporizador e a navegação.
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        width: 2,
                      ),
                    ),
                  ),
                  const NutriLabel('📊', variant: NutriLabelVariant.display),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.secondary,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              NutriLabel(
                'A calcular o teu plano...',
                variant: NutriLabelVariant.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              NutriLabel(
                'Estamos a analisar os teus dados para criar metas de calorias e macros ideais para ti.',
                variant: NutriLabelVariant.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              _buildStep(
                'Analisar perfil biométrico',
                isDone: true,
                colorScheme: colorScheme,
              ),
              _buildStep(
                'Ajustar metas de peso',
                isDone: true,
                colorScheme: colorScheme,
              ),
              _buildStep(
                'Finalizar recomendações',
                isDone: false,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói um indicador visual de um passo do processo de cálculo.
  ///
  /// Exibe um ícone de concluído ou pendente, acompanhado do [title] do passo.
  /// A cor e o ícone variam consoante o parâmetro [isDone].
  Widget _buildStep(
    String title, {
    required bool isDone,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? colorScheme.secondary : colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 12),
          NutriLabel(
            title,
            variant: NutriLabelVariant.body,
            color: isDone
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}