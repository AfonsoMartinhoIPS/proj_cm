import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';


import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_wave_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // ensure provider build kicks off and we react after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkState());
  }

  void _checkState() {
    final state = ref.read(authProvider);
    state.whenOrNull(
      data: (user) => _navigate(user),
      error: (_, _) => _navigate(null),
    );
  }

  Future<void> _navigate(AppUser? user) async {
    if (_navigated) return;
    _navigated = true;
    
    await Future.delayed(const Duration(seconds: 2)); 
    if (!mounted) return;
    if (user != null) {
      logger.d('SplashScreen: user session found, navigating to home');
      //context.go('/');
    } else {
      logger.d('SplashScreen: no user session, navigating to welcome');
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    // catches transitions if build() was still loading when splash mounted
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
                const NutriLabel.rich(
                  variant: NutriLabelVariant.title,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nutri',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Scan',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const NutriLabel(
                  'Come melhor. Vive melhor.',
                  variant: NutriLabelVariant.small,
                  color: AppColors.primary,
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