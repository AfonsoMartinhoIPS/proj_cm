import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/presentation/widgets/nutri_back_button.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';
import 'package:nutri_scan/presentation/widgets/nutri_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: Center(child: NutriBackButton(onPressed: () => context.pop()))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Cria Conta',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Regista-te para começar a monitorizar a tua nutrição.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 35),
                const NutriTextField(
                  label: 'Nome Completo', 
                  hint: 'Ana Ferreira',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                const NutriTextField(
                  label: 'Email', 
                  hint: 'exemplo@email.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                const NutriTextField(
                  label: 'Password', 
                  hint: '••••••••', 
                  obscureText: true,
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 20),
                const NutriTextField(
                  label: 'Confirmar Password', 
                  hint: '••••••••', 
                  obscureText: true,
                  icon: Icons.lock_clock_outlined,
                ),
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
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Aceito os Termos de Serviço e a Política de Privacidade.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),
                NutriButton(
                  text: 'Registar',
                  onPressed: () {},
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}