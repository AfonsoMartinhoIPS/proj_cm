import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_wave_background.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

/// Ecrã de início de sessão.
///
/// Permite ao utilizador autenticar‑se com email e palavra‑passe. Inclui
/// links para recuperação de palavra‑passe e para o ecrã de registo.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// Estado do [LoginScreen] que gere os campos de email e palavra‑passe.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Valida os campos e submete o início de sessão.
  ///
  /// Se o email ou a palavra‑passe estiverem vazios, exibe uma snackbar de erro.
  /// Caso contrário, chama o método de login do [authProvider].
  void submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      NutriFeedback.showSnackBar(
        context,
        'Preenche o email e a password',
        NutriFeedbackType.error,
      );
      return;
    }

    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

    final authState = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: const NutriTopNavBar(showBackButton: true),
      body: WaveBackground(
        child: SafeArea(
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const NutriIcon(fill: true),
                    ),
                    const SizedBox(width: 12),
                    NutriLabel.rich(
                      variant: NutriLabelVariant.headline,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Nutri',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: 'Scan',
                            style: TextStyle(color: colorScheme.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                NutriLabel(
                  'Bem-vindo de volta!',
                  variant: NutriLabelVariant.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                NutriLabel(
                  'Inicia sessão para continuar.',
                  variant: NutriLabelVariant.body,
                  textAlign: TextAlign.center,
                  color: colorScheme.outline,
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
                    onPressed: () {},
                    label: 'Esqueceste a password?',
                  ),
                ),
                const SizedBox(height: 10),
                NutriButton(
                  label: 'Entrar',
                  isLoading: authState.isLoading,
                  onPressed: submit,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: NutriButton.transparent(
                        label: 'Google',
                        icon: Image.asset(
                          'assets/logos/google-logo-50.png',
                          height: 18,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NutriLabel(
                      'Não tens conta? ',
                      variant: NutriLabelVariant.body,
                    ),
                    NutriButton.text(
                      label: 'Registar',
                      onPressed: () =>
                          context.push('/onboarding/personal-data'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}