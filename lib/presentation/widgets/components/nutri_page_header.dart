import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_button.dart';

/// Cabeçalho de página com título, subtítulo e botão de ação opcional.
///
/// Apresenta um título principal, um subtítulo descritivo e, caso fornecidos,
/// um botão de ação alinhado à direita.
class NutriPageHeader extends StatelessWidget {
  /// Título principal do cabeçalho.
  final String title;

  /// Texto descritivo exibido abaixo do [title].
  final String? subtitle;

  /// Rótulo do botão de ação. Se `null`, o botão não é renderizado.
  final String? actionLabel;

  /// Callback invocado quando o botão de ação é pressionado.
  final VoidCallback? onAction;

  /// Ícone do botão de ação. Ignorado se [actionLabel] for `null`.
  final IconData? actionIcon;

  /// Cria um [NutriPageHeader].
  ///
  /// O parâmetro [title] é obrigatório.
  const NutriPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NutriLabel(
                title,
                variant: NutriLabelVariant.headline,
                color: colorScheme.onSurface,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                NutriLabel(
                  subtitle!,
                  variant: NutriLabelVariant.body,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 12),
          NutriButton.text(
            label: actionLabel!,
            onPressed: onAction,
            fontSize: 12,
            icon: actionIcon != null ? Icon(actionIcon) : null,
          ),
        ],
      ],
    );
  }
}