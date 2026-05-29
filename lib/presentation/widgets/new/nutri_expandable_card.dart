import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_card.dart';

/// Card expansível com animação suave para conteúdo oculto.
///
/// Card que se expande/contrai com rotação de ícone e transição de tamanho.
/// Útil para secções de detalhe colapsáveis.
class NutriExpandableCard extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initialExpanded;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;

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
                        color: AppColors.onBackground,
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5)
                          .animate(_controller),
                      child: Icon(
                        Icons.expand_more,
                        color: AppColors.secondary,
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
                  child: Divider(color: AppColors.border),
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
