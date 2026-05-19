import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/theme/app_colors.dart';
import 'package:nutri_scan/core/widgets/nutri_text_field.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche o email e a password')),
      );
      return;
    }

    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) context.go('/');
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        ),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => context.pop(),
        // ),
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
              NutriTextField(
                label: 'Email',
                hint: 'ana@email.com',
                icon: Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 20),
              NutriTextField(
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueceste a password?', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: authState.isLoading ? null : submit,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
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
