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
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal_screen.dart';
import 'package:nutri_scan/presentation/screens/meals/day_detail_screen.dart';

import 'package:nutri_scan/presentation/screens/onboarding/personal_data_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/objectives_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/calculation_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/nutrition_goals_screen.dart';
import 'package:nutri_scan/presentation/screens/onboarding/confirm_screen.dart';

import 'package:nutri_scan/presentation/screens/history/history_screen.dart';
import 'package:nutri_scan/presentation/screens/home/home_screen.dart';
import 'package:nutri_scan/presentation/screens/meals/meals_screen.dart';
import 'package:nutri_scan/presentation/screens/products/products_screen.dart';
import 'package:nutri_scan/presentation/screens/products/product_details_screen.dart';
import 'package:nutri_scan/presentation/screens/scanner/scan_screen.dart';

import 'package:nutri_scan/presentation/screens/profile/profile_screen.dart';
import 'package:nutri_scan/presentation/screens/profile/settings_screen.dart';
import 'package:nutri_scan/presentation/screens/profile/goals_editor_screen.dart';
import 'package:nutri_scan/presentation/screens/profile/credits_screen.dart';

import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Global RouteObserver. Subscribed by widgets (e.g. BarcodeCamera) that need
/// to react when a route is pushed above or popped back to them, beyond what
/// State lifecycle alone provides. Must be plumbed into [GoRouter.observers].
final routeObserver = RouteObserver<ModalRoute<dynamic>>();

/// Singleton reference to the live [GoRouter] instance, captured the first
/// time [routerProvider] resolves. Used by code that lives outside the
/// widget tree (e.g. `NotificationService._onTap`) to navigate without
/// needing a `BuildContext`. Null until the first build resolves the
/// provider, which is fine because cold-launch notifications fall through
/// to the splash → auth-redirect chain anyway.
GoRouter? appRouter;

/// Representa uma rota da barra de navegação inferior.
///
/// Cada instância define o caminho, o rótulo, o ícone e o ecrã associado
/// a uma das abas principais da aplicação.
class AppRoute {
  /// O caminho da rota (ex.: `'/'`, `'/meals'`).
  final String path;

  /// O rótulo exibido na barra de navegação.
  final String label;

  /// O ícone representativo da rota.
  final IconData icon;

  /// O widget que será renderizado quando a rota estiver ativa.
  final Widget screen;

  /// Cria uma [AppRoute].
  ///
  /// Todos os parâmetros são obrigatórios.
  const AppRoute({
    required this.path,
    required this.label,
    required this.icon,
    required this.screen,
  });
}

/// Lista de rotas que compõem a barra de navegação inferior.
///
/// A ordem dos elementos determina a ordem das abas no [NutriBottomBar].
final List<AppRoute> bottomNavRoutes = [
  AppRoute(
      path: '/',
      label: 'Início',
      icon: Icons.home,
      screen: const HomeScreen()),
  AppRoute(
      path: '/meals',
      label: 'Refeições',
      icon: Icons.restaurant,
      screen: const MealsScreen()),
  AppRoute(
      path: '/products',
      label: 'Produtos',
      icon: Icons.inventory_2_outlined,
      screen: const ProductsScreen()),
  AppRoute(
      path: '/scan',
      label: 'Scan',
      icon: Icons.qr_code_scanner,
      screen: const ScanScreen()),
];

/// Rotas que são acessíveis sem autenticação.
const _publicRoutes = ['/splash', '/welcome', '/login', '/register'];

/// Observador de navegação que regista as transições de rota no logger.
///
/// Regista eventos de `push`, `pop` e `replace` para facilitar a depuração
/// do fluxo de navegação.
class _RouteLogger extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    logger.d(
        'Router → push: ${route.settings.name ?? route.settings} (from ${previousRoute?.settings.name ?? '-'})');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logger.d(
        'Router ← pop: ${route.settings.name ?? route.settings} (back to ${previousRoute?.settings.name ?? '-'})');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.d(
        'Router ↔ replace: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
  }
}

/// Notificador que reage a alterações no estado de autenticação.
///
/// Quando o [authProvider] emite um novo valor, este notificador invalida
/// o [GoRouter], forçando a reavaliação das rotas e dos redirecionamentos.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

/// Provider que constrói e configura o [GoRouter] da aplicação.
///
/// Define as rotas públicas, de onboarding e protegidas, incluindo o
/// `ShellRoute` que envolve as abas da navegação inferior.
/// A lógica de redirecionamento garante que utilizadores não autenticados
/// sejam enviados para `/welcome` e que utilizadores autenticados não
/// acedam a ecrãs públicos como o login ou o onboarding.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    observers: [_RouteLogger(), routeObserver],
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;

      final loggedIn = auth.value != null;
      final loc = state.matchedLocation;
      final isPublic =
          _publicRoutes.contains(loc) || loc.startsWith('/onboarding');

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
      // Rotas públicas (sem autenticação)
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),

      // Fluxo de onboarding
      GoRoute(
          path: '/onboarding/personal-data',
          builder: (_, _) => const PersonalDataScreen()),
      GoRoute(
          path: '/onboarding/objectives',
          builder: (_, _) => const ObjectivesScreen()),
      GoRoute(
          path: '/onboarding/calculation',
          builder: (_, _) => const CalculationScreen()),
      GoRoute(
          path: '/onboarding/nutrition-goals',
          builder: (_, _) => const NutritionGoalsScreen()),
      GoRoute(
          path: '/onboarding/confirm',
          builder: (_, _) => const ConfirmScreen()),

      // Rotas protegidas (perfil e definições)
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
          path: '/profile/goals',
          builder: (_, _) => const GoalsEditorScreen()),
      GoRoute(path: '/credits', builder: (_, _) => const CreditsScreen()),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),

      // Rotas de refeições
      GoRoute(
          path: '/meals/add',
          builder: (context, state) =>
              AddMealScreen(initialProduct: state.extra as Product?)),
      GoRoute(
        path: '/meals/edit',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AddMealScreen(
            editingEntry: extra['entry'] as MealEntry,
            editingDate: extra['date'] as String,
          );
        },
      ),
      GoRoute(
        path: '/meals/day/:date',
        builder: (context, state) =>
            DayDetailScreen(date: state.pathParameters['date']!),
      ),

      // Detalhes do produto
      GoRoute(
        path: '/products/:barcode',
        builder: (context, state) =>
            ProductDetailsScreen(barcode: state.pathParameters['barcode']!),
      ),

      // Scanner em modo de seleção (devolve o código de barras via pop)
      GoRoute(
        path: '/scanner/pick',
        builder: (_, _) => const ScanScreen(returnBarcode: true),
      ),

      // Shell que envolve as abas da navegação inferior
      ShellRoute(
        builder: (context, state, child) => NutriMainShell(child: child),
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

  appRouter = router;
  return router;
});