import 'package:flutter/material.dart';
import 'package:nutri_scan/core/router/app_router.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        for (final route in bottomNavRoutes)
          BottomNavigationBarItem(
            icon: Icon(route.icon),
            label: route.label,
          ),
      ],
    );
  }
}
