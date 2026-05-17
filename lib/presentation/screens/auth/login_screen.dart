import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/widgets/nutri_text_field.dart';
import 'package:projeto/core/widgets/nutri_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppColors.onBackground, size: 24),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'Nutri', style: TextStyle(color: AppColors.onBackground, fontSize: 24, fontWeight: FontWeight.bold)),
                        TextSpan(text: 'Scan', style: TextStyle(color: AppColors.secondary,    fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text('Bem-vindo de volta!', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onBackground, fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Inicia sessão para continuar.', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.border, fontSize: 14)),
              const SizedBox(height: 40),
              NutriTextField(label: 'Email', hintText: 'teste@mail.com',),
              const SizedBox(height: 40), // adicionar padding ao NutriTextField mais tarde
              NutriTextField(label: 'PassWord', hintText: '*****', obscureText: true,),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueceste a password?', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 10),
              NutriButton(text: 'Login', onPressed: () => context.go('/'),),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ou continua com', style: const TextStyle(color: AppColors.border, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Google'))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Apple'))),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tens conta? ', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text('Registar',
                        style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
