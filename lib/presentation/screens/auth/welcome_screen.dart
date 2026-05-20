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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 3),
                  ),
                  child: const Center(child: Text('🥗', style: TextStyle(fontSize: 50))),
                ),
              ),
              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'Bem-vindo ao\n', style: TextStyle(color: AppColors.onBackground)),
                    TextSpan(text: 'NutriScan', style: TextStyle(color: AppColors.secondary)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'A tua app de nutrição pessoal.\nMonitoriza, aprende e atinge os teus objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
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
          Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 11)),
        ],
      ),
    );
  }
}
