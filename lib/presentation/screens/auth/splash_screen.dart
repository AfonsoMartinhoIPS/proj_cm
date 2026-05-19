import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                child: Image.asset(
                  'assets/icon/icon.png',
                  fit: BoxFit.contain,
                ),
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
