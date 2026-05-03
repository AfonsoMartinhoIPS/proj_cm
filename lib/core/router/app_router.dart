import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/presentation/screens/home/home_screen.dart';
import 'package:projeto/presentation/screens/products/products_screen.dart';
import 'package:projeto/presentation/screens/profile/profile_screen.dart';
import 'package:projeto/presentation/screens/scanner/scan_screen.dart';
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
  AppRoute(path: '/',         label: 'Home',     icon: Icons.home,          screen: const HomeScreen()),
  AppRoute(path: '/meals',  label: 'Meals',  icon: Icons.restaurant,        screen: const ProfileScreen()),
  AppRoute(path: '/products', label: 'Products', icon: Icons.search,        screen: const ProductsScreen()),
  AppRoute(path: '/scan',     label: 'Scan',     icon: Icons.qr_code,       screen: const ScanScreen()),
];

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
