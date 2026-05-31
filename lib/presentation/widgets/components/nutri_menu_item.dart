import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Item de menu com ícone, rótulo e opção destrutiva.
///
/// Apresenta uma linha clicável com um [icon] à esquerda, um [label] descritivo
/// e um widget opcional à direita ([trailing]). O modo [destructive] aplica
/// a cor de erro do tema ao ícone e ao texto, sendo adequado para ações
/// críticas como "Apagar conta" ou "Terminar sessão".
class NutriMenuItem extends StatelessWidget {
  /// Ícone exibido no início do item.
  final IconData icon;

  /// Texto descritivo da ação.
  final String label;

  /// Callback invocado quando o item é tocado.
  final VoidCallback onTap;

  /// Se `true`, o item é apresentado com a cor de erro do tema.
  ///
  /// O valor padrão é `false`.
  final bool destructive;

  /// Widget opcional exibido no final do item.
  final Widget? trailing;

  /// Cria um [NutriMenuItem].
  ///
  /// Os parâmetros [icon], [label] e [onTap] são obrigatórios.
  const NutriMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = destructive ? colorScheme.error : colorScheme.secondary;
    final textColor = destructive ? colorScheme.error : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: NutriLabel(
                  label,
                  variant: NutriLabelVariant.body,
                  color: textColor,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}