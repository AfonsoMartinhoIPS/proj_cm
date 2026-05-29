import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_button.dart';

/// Estado vazio centrado com ícone, título, subtítulo e ação opcional.
///
/// Exibe feedback visual quando não há dados ou resultados (busca vazia, lista vazia, etc).
/// Suporta ícone customizado ou widget, título, subtítulo e botão de ação.
class NutriEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const NutriEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: AppColors.textMuted,
              ),
            if (icon != null || customIcon != null) const SizedBox(height: 16),
            NutriLabel(
              title,
              variant: NutriLabelVariant.headline,
              textAlign: TextAlign.center,
              color: AppColors.onBackground,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              NutriLabel(
                subtitle!,
                variant: NutriLabelVariant.body,
                textAlign: TextAlign.center,
                color: AppColors.textMuted,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: NutriButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
