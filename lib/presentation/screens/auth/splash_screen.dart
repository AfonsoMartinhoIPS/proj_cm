// lib/presentation/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_wave_background.dart';

/// Ecrã de apresentação (splash) exibido durante o arranque da aplicação.
///
/// Enquanto o estado de autenticação é resolvido, mostra o logótipo e o
/// slogan da aplicação sobre um fundo animado. Após um breve atraso,
/// redireciona o utilizador para o ecrã principal (se já tiver sessão)
/// ou para o ecrã de boas‑vindas.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// Estado do [SplashScreen] que monitoriza o estado de autenticação
/// e controla a navegação inicial.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Dispara a verificação do estado de autenticação assim que o primeiro
    // frame for desenhado.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkState());
  }

  /// Lê o estado atual do [authProvider] e inicia a navegação adequada.
  void _checkState() {
    final state = ref.read(authProvider);
    state.whenOrNull(
      data: (user) => _navigate(user),
      error: (_, _) => _navigate(null),
    );
  }

  /// Navega para o ecrã principal ou de boas‑vindas consoante a existência
  /// de um utilizador autenticado.
  ///
  /// A navegação é feita após um pequeno atraso para permitir que a animação
  /// do splash seja visível. Uma flag interna garante que a navegação só
  /// ocorre uma vez.
  Future<void> _navigate(AppUser? user) async {
    if (_navigated) return;
    _navigated = true;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (user != null) {
      logger.d('SplashScreen: user session found, navigating to home');
      context.go('/');
    } else {
      logger.d('SplashScreen: no user session, navigating to welcome');
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Reage a alterações posteriores do estado de autenticação (ex.: login
    // automático resolvido após o primeiro build).
    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        data: (user) => _navigate(user),
        error: (_, _) => _navigate(null),
      );
    });

    return Scaffold(
      body: WaveBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NutriIcon(size: 80),
                const SizedBox(height: 24),
                NutriLabel.rich(
                  variant: NutriLabelVariant.title,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nutri',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Scan',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NutriLabel(
                  'Come melhor. Vive melhor.',
                  variant: NutriLabelVariant.small,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}