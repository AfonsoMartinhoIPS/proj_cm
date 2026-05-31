import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_card.dart';

/// Card que pode ser expandido ou colapsado com animação suave.
///
/// Exibe um cabeçalho com o [title] e um ícone de seta que roda conforme
/// o estado de expansão. Quando expandido, mostra o [child] abaixo de um
/// divisor. Suporta callbacks para os eventos de expansão e colapso.
class NutriExpandableCard extends StatefulWidget {
  /// O título exibido no cabeçalho do card.
  final String title;

  /// O conteúdo revelado quando o card está expandido.
  final Widget child;

  /// Controla se o card deve iniciar expandido.
  ///
  /// O valor padrão é `false`.
  final bool initialExpanded;

  /// Callback invocado quando o card termina a animação de expansão.
  final VoidCallback? onExpanded;

  /// Callback invocado quando o card termina a animação de colapso.
  final VoidCallback? onCollapsed;

  /// Cria um [NutriExpandableCard].
  ///
  /// Os parâmetros [title] e [child] são obrigatórios.
  const NutriExpandableCard({
    super.key,
    required this.title,
    required this.child,
    this.initialExpanded = false,
    this.onExpanded,
    this.onCollapsed,
  });

  @override
  State<NutriExpandableCard> createState() => _ExpandableCardState();
}

/// Estado do [NutriExpandableCard] que gere a animação de expansão/colapso.
class _ExpandableCardState extends State<NutriExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Alterna o estado do card entre expandido e colapsado,
  /// disparando os callbacks correspondentes.
  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _controller.forward();
      widget.onExpanded?.call();
    } else {
      _controller.reverse();
      widget.onCollapsed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NutriCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: NutriLabel(
                        widget.title,
                        variant: NutriLabelVariant.body,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5)
                          .animate(_controller),
                      child: Icon(
                        Icons.expand_more,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _controller,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  child: Divider(color: colorScheme.outline),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.md,
                    right: AppSizes.md,
                    bottom: AppSizes.md,
                  ),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}