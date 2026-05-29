import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_button.dart';

/// Cabeçalho de página com título, subtítulo e botão de ação opcional.
///
/// Componente para o topo de ecrãs com suporte a ação com rótulo e ícone.
class NutriPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

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
                color: AppColors.onBackground,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                NutriLabel(
                  subtitle!,
                  variant: NutriLabelVariant.body,
                  color: AppColors.textMuted,
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
