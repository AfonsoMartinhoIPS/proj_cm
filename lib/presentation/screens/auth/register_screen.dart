import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

/// Ecrã de registo de uma nova conta.
///
/// Recolhe o nome, email e palavra‑passe do utilizador e submete os dados
/// através do [authProvider] em conjunto com as informações de onboarding
/// já recolhidas. Inclui validação local para garantir que todos os campos
/// estão preenchidos e que as palavras‑passe coincidem.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// Estado do [RegisterScreen] que gere os campos de texto e a submissão.
///
/// Apenas pede email + password (+ confirmação). O nome já foi recolhido
/// no primeiro passo do onboarding (`PersonalDataScreen`) e vive no
/// [onboardingProvider]; pedir de novo aqui levaria a duplicação ou
/// sobreposição silenciosa do valor.
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida os campos e submete o registo.
  ///
  /// Verifica se todos os campos estão preenchidos e se as palavras‑passe
  /// coincidem. Em caso de erro, exibe uma snackbar. Se tudo estiver correto,
  /// transfere as credenciais para o [onboardingProvider] e invoca o registo
  /// no [authProvider] com o estado de onboarding já completo (incluindo o
  /// nome recolhido na `PersonalDataScreen`).
  void submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final onboarding = ref.read(onboardingProvider);

    if (onboarding.name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      NutriFeedback.showSnackBar(
        context,
        'Preenche todos os campos',
        NutriFeedbackType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      NutriFeedback.showSnackBar(
        context,
        'As passwords não coincidem',
        NutriFeedbackType.error,
      );
      return;
    }

    ref
        .read(onboardingProvider.notifier)
        .setCredentials(email: email, password: password);
    ref.read(authProvider.notifier).register(ref.read(onboardingProvider));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) context.go('/');
        },
        error: (e, _) {
          NutriFeedback.showSnackBar(
            context,
            e.toString(),
            NutriFeedbackType.error,
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(
        showBackButton: true,
        title: 'Cria Conta',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              NutriLabel(
                'Cria Conta',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              NutriLabel(
                'Regista-te para começar a monitorizar a tua nutrição.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 35),
              NutriTextField(
                controller: emailController,
                label: 'Email',
                hint: 'exemplo@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              NutriTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              NutriTextField(
                controller: confirmPasswordController,
                label: 'Confirmar Password',
                icon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: NutriLabel(
                      'Aceito os Termos de Serviço e a Política de Privacidade.',
                      variant: NutriLabelVariant.small,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              NutriButton(
                label: 'Registar',
                isLoading: authState.isLoading,
                onPressed: submit,
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}