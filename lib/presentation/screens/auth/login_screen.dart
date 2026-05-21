import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
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
        const SnackBar(content: NutriLabel('Preenche o email e a password', variant: NutriLabelVariant.small, color: AppColors.error)),
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
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))), //TODO: Trocar para NutriLabel????
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
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.onBackground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const NutriLabel.rich(
                    variant: NutriLabelVariant.headline,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nutri',
                          style: TextStyle(color: AppColors.onBackground),
                        ),
                        TextSpan(
                          text: 'Scan',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const NutriLabel(
                'Bem-vindo de volta!',
                variant: NutriLabelVariant.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const NutriLabel(
                'Inicia sessão para continuar.',
                variant: NutriLabelVariant.body,
                textAlign: TextAlign.center,
                color: AppColors.border,
              ),
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
                child: NutriButton.text(
                  onPressed: () {}, //TODO: Inserir lógica de recuperação de password
                  label: 'Esqueceste a password?',
                ),
              ),
              const SizedBox(height: 10),
              NutriButton(
                label: 'Entrar',
                isLoading: authState
                    .isLoading, // O teu botão esconde o texto e mostra o progresso sozinho
                onPressed: submit,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: NutriButton.transparent(
                      label: 'Google',
                      // height: 20 garante que o logo não deforma o botão de 45px
                      icon: Image.asset(
                        'assets/logos/google-logo-50.png',
                        height: 18,
                      ),
                      onPressed: () {
                        // Samuel: Inserir a lógica de login do Google aqui
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NutriButton.transparent(
                      label: 'Apple',
                      icon: Image.asset(
                        'assets/logos/apple-logo-50.png',
                        height: 18,
                        // Garante que o logo da Apple fica com a cor dinâmica do tema/texto
                        color: AppColors.onBackground,
                      ),
                      onPressed: () {
                        // Samuel: Inserir a lógica de login da Apple aqui
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NutriLabel(
                    'Não tens conta? ',
                    variant: NutriLabelVariant.body,
                  ),
                  NutriButton.text(
                    label: 'Registar',
                    onPressed: () => context.push('/register'),
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
