import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/utils/logger.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

import 'package:nutri_scan/presentation/screens/auth/splash_screen.dart';
import 'package:nutri_scan/presentation/screens/auth/welcome_screen.dart';
import 'package:nutri_scan/presentation/screens/auth/login_screen.dart';
import 'package:nutri_scan/presentation/screens/auth/register_screen.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal_screen.dart';

import 'package:nutri_scan/presentation/screens/onboarding/personal_data_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/objectives_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/calculation_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/nutrition_goals_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/confirm_screen.dart';

import 'package:nutri_scan/presentation/screens/home/home_screen.dart';
import 'package:nutri_scan/presentation/screens/meals/meals_screen.dart';
import 'package:nutri_scan/presentation/screens/products/products_screen.dart';
import 'package:nutri_scan/presentation/screens/products/product_details_screen.dart';
import 'package:nutri_scan/presentation/screens/scanner/scan_screen.dart';

import 'package:nutri_scan/presentation/screens/profile/profile_screen.dart';
import 'package:nutri_scan/presentation/screens/profile/settings_screen.dart';
import 'package:nutri_scan/presentation/screens/profile/credits_screen.dart';

import 'package:nutri_scan/presentation/widgets/old_widgets.dart';

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

const _publicRoutes = ['/splash', '/welcome', '/login', '/register'];

class _RouteLogger extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    logger.d('Router → push: ${route.settings.name ?? route.settings} (from ${previousRoute?.settings.name ?? '-'})');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logger.d('Router ← pop: ${route.settings.name ?? route.settings} (back to ${previousRoute?.settings.name ?? '-'})');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.d('Router ↔ replace: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
  }
}

// bridge auth state changes → router refresh
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    observers: [_RouteLogger()],
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      // wait for build to finish before deciding
      if (auth.isLoading) return null;

      final loggedIn = auth.value != null;
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc) || loc.startsWith('/onboarding');

      if (!loggedIn && !isPublic) {
        logger.d('Router redirect: not logged in, → /welcome');
        return '/welcome';
      }
      if (loggedIn && isPublic) {
        logger.d('Router redirect: already logged in, → /');
        return '/';
      }
      return null;
    },
    routes: [

      // public
      GoRoute(path: '/splash',   builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome',  builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login',    builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),


      // onboarding
      GoRoute(path: '/onboarding/personal-data',   builder: (_, _) => const PersonalDataScreen()),
      GoRoute(path: '/onboarding/objectives',      builder: (_, _) => const ObjectivesScreen()),
      GoRoute(path: '/onboarding/calculation',     builder: (_, _) => const CalculationScreen()),
      GoRoute(path: '/onboarding/nutrition-goals', builder: (_, _) => const NutritionGoalsScreen()),
      GoRoute(path: '/onboarding/confirm',         builder: (_, _) => const ConfirmScreen()),

      // protected
      GoRoute(path: '/profile',  builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/credits',  builder: (_, _) => const CreditsScreen()),
      
      // meals
      GoRoute(path: '/meals/add', builder: (context, state) => AddMealScreen(initialProduct: state.extra as Product?,)),
      GoRoute(
        path: '/products/:barcode',
        builder: (context, state) => ProductDetailsScreen(
          barcode: state.pathParameters['barcode']!,
        ),
      ),

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
});
