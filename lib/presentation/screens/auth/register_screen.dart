import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/onboarding_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
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
    final onboarding = ref.read(onboardingProvider).copyWith(name: name);
    ref.read(authProvider.notifier).register(onboarding);
  }

  @override
  Widget build(BuildContext context) {
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
        }
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
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
              const NutriLabel(
                'Cria Conta',
                variant: NutriLabelVariant.display,
              ),
              const SizedBox(height: 10),
              const NutriLabel(
                'Regista-te para começar a monitorizar a tua nutrição.',
                variant: NutriLabelVariant.small,
              ),
              const SizedBox(height: 35),
              NutriTextField(
                controller: nameController,
                label: 'Nome Completo',
                hint: 'Ana Ferreira',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
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
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              NutriTextField(
                controller: confirmPasswordController,
                label: 'Confirmar Password',
                hint: '••••••••',
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
