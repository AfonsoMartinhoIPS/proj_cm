import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (_, next) {
      next.when(
        data: (user) async {
          await Future.delayed(const Duration(seconds: 1)); // minimum splash time
          if (user != null) {
            context.go('/');
          } else {
            context.go('/welcome');
          }
        },
        error: (_, _) => context.go('/welcome'),
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nutri',
                      style: TextStyle(color: AppColors.onBackground, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Scan',
                      style: TextStyle(color: AppColors.secondary, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Come melhor. Vive melhor.',
                style: TextStyle(color: AppColors.primary, fontSize: 14, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
