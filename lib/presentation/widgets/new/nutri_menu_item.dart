import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Item de menu com ícone, rótulo e opções visuais destrutivas.
///
/// Elemento clicável para menus, listas de ações ou painéis de configuração.
/// Suporta ícone leadingg, widget trailing customizado e estilo destrutivo para ações críticas.
class NutriMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

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
    final iconColor = destructive ? AppColors.error : AppColors.secondary;
    final textColor = destructive ? AppColors.error : AppColors.onBackground;

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
