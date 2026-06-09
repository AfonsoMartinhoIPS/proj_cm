// lib/presentation/screens/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_wave_background.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de boas‑vindas apresentado a utilizadores não autenticados.
///
/// Mostra o logótipo da aplicação, uma breve descrição das funcionalidades
/// principais e botões para iniciar o registo ou entrar com uma conta existente.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: WaveBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: NutriIcon(size: 100, fill: true),
                ),
                const SizedBox(height: 30),
                NutriLabel.rich(
                  variant: NutriLabelVariant.headline,
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bem-vindo ao\n',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: 'NutriScan',
                        style: TextStyle(color: colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                NutriLabel(
                  'A tua app de nutrição pessoal.\nMonitoriza, aprende e atinge os teus objetivos.',
                  variant: NutriLabelVariant.body,
                  textAlign: TextAlign.center,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTag('Scan de produtos', colorScheme),
                    _buildTag('Registo de refeições', colorScheme),
                    _buildTag('Objetivos personalizados', colorScheme),
                  ],
                ),
                const Spacer(),
                NutriButton(
                  label: 'Começar agora',
                  onPressed: () => context.push('/onboarding/personal-data'),
                ),
                const SizedBox(height: 15),
                NutriButton.transparent(
                  label: 'Já tenho conta · ',
                  onPressed: () => context.push('/login'),
                  secondaryLabel: 'Entrar',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói uma pequena etiqueta decorativa com um ponto colorido e o texto
  /// da funcionalidade.
  Widget _buildTag(String label, ColorScheme colorScheme) {
    return NutriCard(
      variant: NutriCardVariant.surfaceDark,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: colorScheme.primary),
          const SizedBox(width: 8),
          NutriLabel(
            label,
            variant: NutriLabelVariant.small,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}