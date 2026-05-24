// lib/presentation/widgets/bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Uma barra de navegação inferior, responsiva.
///
/// O [NutriBottomBar] itera dinamicamente sobre o `bottomNavRoutes` que está no router.
/// Garante que qualquer reordenação ou mudança de ecrãs no `app_router.dart`
/// reflete de forma imediata na UI sem percisar de alterações neste ficheiro.
///
/// ### Responsividade e Layout
/// - **Mobile (Ecrãs Estreitos):** Distribui as margens uniformemente ao longo de toda a largura
///   com um espaçamento horizontal ([AppSizes.sm]).
/// - **Tablets / Landscape (Ecrãs Largos > 600dp):** Margens horizontais dinâmicas de 15%
///   com base no tamanho máximo do ecrã ([LayoutBuilder]) para agrupar os botões no centro.
/// - **Tratamento de Insets:** Uma [SafeArea] que ignora o topo mas "consome" as
///   propriedades físicas do padding inferior do dispositivo (ex: barras de navegação do Android),
///   somando à altura do [AppSizes.bottomNavHeight].
class NutriBottomBar extends StatelessWidget {
  /// O índice numérico, começa em zero, da aba atualmente ativa.
  ///
  /// Controla o estado visual, alternando a cor
  /// dos subcomponentes do ícone e texto entre [AppColors.secondary] (ativo)
  /// e [AppColors.textMuted] (inativo).
  final int currentIndex;

  /// Callback sempre que uma aba é pressionada.
  ///
  /// Devolve o índice original correspondente à aba clicada na lista global,
  /// permitindo que o GoRouter
  /// execute a transição correta para o caminho pretendido.
  final Function(int) onTap;

  /// Construtor do [NutriBottomBar].
  ///
  /// Requer obrigatoriamente o [currentIndex] para gerir o estado ativo e o [onTap]
  /// para os eventos de toque.
  const NutriBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Deteta se a largura atual do ecrã excede os limites de um telemovel "convencional"
        final isWideScreen = constraints.maxWidth > 600;

        return Container(
          // Garante que o container se expande verticalmente
          height:
              AppSizes.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.surfaceDark, width: 1.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen
                    ? constraints.maxWidth * 0.15
                    : AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //IMPORTANTE: se quiserem trocar a ordem do menu troquem no app_router.dart sff
                  for (int i = 0; i < bottomNavRoutes.length; i++)
                    _buildItem(i, bottomNavRoutes[i]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói uma aba individual da barra de navegação.
  /// 
  /// Utiliza um [NutriLabel]
  /// configurado no modo [NutriLabelVariant.small].
  ///
  /// - [index]: O índice da aba em atual.
  /// - [route]: O `AppRoute` que detém a label, o ícone e o path.
  Widget _buildItem(int index, AppRoute route) {
    final bool isActive = currentIndex == index;
    final Color effectiveColor = isActive
        ? AppColors.secondary
        : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        highlightColor: Colors.transparent,
        splashColor: AppColors.surfaceLight.withValues(alpha: 0.15),
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
