// lib/presentation/widgets/new/onboarding_step_indicator.dart
import 'package:flutter/material.dart';

/// Indicador de progresso visual para ecrãs de onboarding.
///
/// Exibe uma linha horizontal de pequenas barras que representam os passos
/// de um fluxo. O passo atual é destacado com a cor primária, os passos
/// concluídos aparecem com opacidade reduzida e os passos futuros são exibidos
/// com uma cor neutra.
class OnboardingStepIndicator extends StatelessWidget {
  /// O número do passo atual (baseado em 1).
  ///
  /// Deve estar entre 1 e [totalSteps], inclusive.
  final int currentStep;

  /// O número total de passos do fluxo.
  final int totalSteps;

  /// Cria um [OnboardingStepIndicator].
  ///
  /// Os parâmetros [currentStep] e [totalSteps] são obrigatórios.
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 16.0 : 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : isDone
                      ? colorScheme.primary.withValues(alpha: 0.4)
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        );
      }),
    );
  }
}