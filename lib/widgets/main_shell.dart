import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/router/app_router.dart';
import 'package:projeto/widgets/bottom_navbar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = bottomNavRoutes.indexWhere(
      (route) => route.path == '/' ? location == '/' : location.startsWith(route.path),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex.clamp(0, bottomNavRoutes.length - 1),
        onTap: (index) => context.go(bottomNavRoutes[index].path),
      ),
    );
  }
}
