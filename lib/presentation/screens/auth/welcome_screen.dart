import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  child: Center(
                    //TODO: Emoji subestituido por imagem, e tamanho aumentado. É preciso escolher um icon melhor.
                    child: NutriIcon(size: 100,fill: true),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const NutriLabel.rich(
                variant: NutriLabelVariant.headline,
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bem-vindo ao\n',
                      style: TextStyle(color: AppColors.onBackground),
                    ),
                    TextSpan(
                      text: 'NutriScan',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const NutriLabel(
                'A tua app de nutrição pessoal.\nMonitoriza, aprende e atinge os teus objetivos.',
                variant: NutriLabelVariant.body,
                textAlign: TextAlign.center,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildTag('Scan de produtos'),
                  _buildTag('Registo de refeições'),
                  _buildTag('Objetivos personalizados'),
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
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
          const SizedBox(width: 8),
          NutriLabel(
            label,
            variant: NutriLabelVariant.small,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
