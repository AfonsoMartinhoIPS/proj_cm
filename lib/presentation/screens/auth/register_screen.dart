import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/presentation/widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form( // Wrap with Form for validation capabilities
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('Cria Conta', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('Regista-te para começar a monitorizar a tua nutrição.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 35),
              const AppTextField(label: 'Nome Completo', hint: 'Ana Ferreira', icon: Icons.person),
              const SizedBox(height: 20),
              const AppTextField(label: 'Email', hint: 'exemplo@email.com', icon: Icons.email_outlined),
              const SizedBox(height: 20),
              const AppTextField(label: 'Password', hint: '••••••••', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 20),
              const AppTextField(label: 'Confirmar Password', hint: '••••••••', icon: Icons.lock_reset_outlined, isPassword: true),
              const SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.check, size: 14, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12), // This is a custom checkbox, could be a reusable widget if needed elsewhere.
                  Expanded(
                    child: Text(
                      'Aceito os Termos de Serviço e a Política de Privacidade.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
              )],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Registar'),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
        )),
    );
  }
}
