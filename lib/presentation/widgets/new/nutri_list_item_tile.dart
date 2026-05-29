import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Item de lista genérico com ícone leadingg, título, subtítulo e ações.
///
/// Linha clicável para exibir itens em listas, com suporte para ícone,
/// widget leadingg customizado, widget trailing e ação de eliminação.
class NutriListItemTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NutriListItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (leading != null)
              leading!
            else if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    title,
                    variant: NutriLabelVariant.body,
                    color: AppColors.onBackground,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    NutriLabel(
                      subtitle!,
                      variant: NutriLabelVariant.small,
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
