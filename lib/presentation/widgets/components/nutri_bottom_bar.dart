import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Barra de navegação inferior responsiva.
///
/// Constrói dinamicamente os itens com base nas rotas definidas em
/// [bottomNavRoutes]. Em ecrãs largos (>600dp) centraliza os ícones,
/// em ecrãs estreitos distribui‑os uniformemente.
///
/// O estado ativo de cada aba é determinado por [currentIndex].
class NutriBottomBar extends StatelessWidget {
  /// O índice da aba atualmente selecionada (baseado em zero).
  final int currentIndex;

  /// Callback invocado quando uma aba é tocada.
  ///
  /// Recebe o índice da aba correspondente.
  final Function(int) onTap;

  /// Cria uma [NutriBottomBar].
  ///
  /// Ambos [currentIndex] e [onTap] são obrigatórios.
  const NutriBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        return Container(
          height:
              AppSizes.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.surfaceContainerHighest,
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isWideScreen ? constraints.maxWidth * 0.15 : AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < bottomNavRoutes.length; i++)
                    _buildItem(i, bottomNavRoutes[i], colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o item de navegação para a [route] na posição [index].
  Widget _buildItem(int index, AppRoute route, ColorScheme colorScheme) {
    final bool isActive = currentIndex == index;
    final Color effectiveColor =
        isActive ? colorScheme.secondary : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        highlightColor: Colors.transparent,
        splashColor: colorScheme.secondary.withValues(alpha: 0.15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(route.icon, color: effectiveColor, size: AppSizes.iconMd),
            const SizedBox(height: AppSizes.xs),
            NutriLabel(
              route.label,
              variant: NutriLabelVariant.small,
              color: effectiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}