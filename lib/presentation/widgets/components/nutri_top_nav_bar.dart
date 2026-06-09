import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Uma barra de navegação superior (`AppBar`) personalizada e reutilizável.
///
/// Alinha o conteúdo à esquerda por padrão e oferece um botão de retroceder
/// condicional (baseado no histórico de navegação do `go_router`).
/// Suporta título simples ou um widget de título personalizado, bem como
/// ações adicionais à direita.
class NutriTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// O texto simples a ser exibido como título.
  ///
  /// Ignorado se [titleWidget] for fornecido.
  final String? title;

  /// Widget personalizado para o título.
  ///
  /// Tem prioridade sobre [title]. Ideal para estruturas complexas como
  /// linhas com múltiplos elementos (ex.: ícone + nome).
  final Widget? titleWidget;

  /// Controla a visibilidade do botão de retroceder.
  ///
  /// O botão só é renderizado se esta flag for `true` **e** o histórico
  /// do `go_router` permitir navegação para trás.
  ///
  /// O valor padrão é `true`.
  final bool showBackButton;

  /// Lista de widgets a apresentar no canto superior direito.
  ///
  /// Normalmente utilizada para botões de ação ou atalhos.
  final List<Widget>? actions;

  /// Cria uma [NutriTopNavBar].
  ///
  /// Pelo menos um título (seja via [title] ou [titleWidget]) é esperado
  /// para uma boa usabilidade, mas não é obrigatório.
  const NutriTopNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              color: colorScheme.onSurface,
              onPressed: () => context.pop(),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth),
                      child: NutriLabel(
                        title!,
                        variant: NutriLabelVariant.title,
                      ),
                    );
                  },
                )
              : null),
      actions: actions,
    );
  }

  @override
  /// O tamanho preferido da barra, correspondente à altura padrão
  /// de uma [AppBar] (`kToolbarHeight`).
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}