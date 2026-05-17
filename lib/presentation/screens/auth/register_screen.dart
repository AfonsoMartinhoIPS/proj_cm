import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/widgets/nutri_back_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: NutriBackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
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
              _buildInputField(
                label: 'Nome Completo',
                hint: 'Ana Ferreira',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Email',
                hint: 'exemplo@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Confirmar Password',
                hint: '•••••••kk•',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
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
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Registar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            obscureText: isPassword,
            style: const TextStyle(color: AppColors.onBackground),
            decoration: InputDecoration(
              icon: Icon(icon, color: AppColors.primary, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.border, fontSize: 14),
              border: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}
