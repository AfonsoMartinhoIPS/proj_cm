// lib/presentation/widgets/nutri_top_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class NutriTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget; // 🚀 Permite passar estruturas complexas sem dar overflow
  final bool showBackButton;
  final List<Widget>? actions;

  const NutriTopNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false, // 🚀 Alinhado à esquerda para dar um ar mais moderno e espaço ao nome
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              color: AppColors.onBackground,
              onPressed: () => context.pop(),
            )
          : null,
      // Se passares um titleWidget ele usa, caso contrário usa a string simples com proteção de overflow
      title: titleWidget ?? (title != null 
          ? LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: NutriLabel(
                    title!, 
                    variant: NutriLabelVariant.title,
                    // Se o teu NutriLabel não aceitar overflow/maxLines, garante que os passas no TextStyle interno
                  ),
                );
              },
            )
          : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}