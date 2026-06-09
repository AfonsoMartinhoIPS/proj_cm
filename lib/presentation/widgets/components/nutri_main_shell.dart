import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/router/app_router.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_bottom_bar.dart';

/// Shell principal da aplicação que envolve as rotas da navegação inferior.
///
/// Fornece a estrutura comum a todos os ecrãs acessíveis pela barra de
/// navegação inferior. Determina o índice ativo com base na localização atual
/// e renderiza o [NutriBottomBar] correspondente.
class NutriMainShell extends StatelessWidget {
  /// O conteúdo da rota ativa, injetado pelo [ShellRoute].
  final Widget child;

  /// Cria uma [NutriMainShell].
  ///
  /// O parâmetro [child] é obrigatório e é fornecido automaticamente
  /// pelo sistema de rotas.
  const NutriMainShell({super.key, required this.child});

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