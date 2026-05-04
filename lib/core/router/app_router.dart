import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projeto/presentation/screens/auth/splash_screen.dart';
import 'package:projeto/presentation/screens/auth/welcome_screen.dart';
import 'package:projeto/presentation/screens/auth/login_screen.dart';
import 'package:projeto/presentation/screens/auth/register_screen.dart';

import 'package:projeto/presentation/screens/onboarding/personal_data_screen.dart';
import 'package:projeto/presentation/screens/onboarding/objectives_screen.dart';
import 'package:projeto/presentation/screens/onboarding/calculation_screen.dart';
import 'package:projeto/presentation/screens/onboarding/estimate_screen.dart';
import 'package:projeto/presentation/screens/onboarding/confirm_screen.dart';

import 'package:projeto/presentation/screens/home/home_screen.dart';
import 'package:projeto/presentation/screens/meals/meals_screen.dart';
import 'package:projeto/presentation/screens/products/products_screen.dart';
import 'package:projeto/presentation/screens/scanner/scan_screen.dart';

import 'package:projeto/presentation/screens/profile/profile_screen.dart';
import 'package:projeto/presentation/screens/profile/settings_screen.dart';
import 'package:projeto/presentation/screens/profile/credits_screen.dart';

import 'package:projeto/presentation/widgets/main_shell.dart';

class AppRoute {
  final String path;
  final String label;
  final IconData icon;
  final Widget screen;

  const AppRoute({
    required this.path,
    required this.label,
    required this.icon,
    required this.screen,
  });
}

final List<AppRoute> bottomNavRoutes = [
  AppRoute(path: '/',         label: 'Início',    icon: Icons.home,                  screen: const HomeScreen()),
  AppRoute(path: '/meals',    label: 'Refeições', icon: Icons.restaurant,            screen: const MealsScreen()),
  AppRoute(path: '/products', label: 'Produtos',  icon: Icons.inventory_2_outlined,  screen: const ProductsScreen()),
  AppRoute(path: '/scan',     label: 'Scan',      icon: Icons.qr_code_scanner,       screen: const ScanScreen()),
];

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',   builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/welcome',  builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/login',    builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),

    GoRoute(path: '/onboarding/personal-data', builder: (_, _) => const PersonalDataScreen()),
    GoRoute(path: '/onboarding/objectives',    builder: (_, _) => const ObjectivesScreen()),
    GoRoute(path: '/onboarding/calculation',   builder: (_, _) => const CalculationScreen()),
    GoRoute(path: '/onboarding/estimate',      builder: (_, _) => const EstimateScreen()),
    GoRoute(path: '/onboarding/confirm',       builder: (_, _) => const ConfirmScreen()),

    GoRoute(path: '/profile',  builder: (_, _) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/credits',  builder: (_, _) => const CreditsScreen()),

    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        for (final route in bottomNavRoutes)
          GoRoute(
            path: route.path,
            builder: (context, state) => route.screen,
          ),
      ],
    ),
  ],
);
