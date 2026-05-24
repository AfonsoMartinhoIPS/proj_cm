import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/router/app_router.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_bottom_bar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = bottomNavRoutes.indexWhere(
      (r) => r.path == '/' ? location == '/' : location.startsWith(r.path),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NutriBottomBar(
        currentIndex: currentIndex.clamp(0, bottomNavRoutes.length - 1),
        onTap: (index) => context.go(bottomNavRoutes[index].path),
      ),
    );
  }
}
