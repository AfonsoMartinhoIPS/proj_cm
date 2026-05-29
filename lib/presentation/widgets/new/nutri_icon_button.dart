import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Botão de ícone com fundo, borda e estilo customizável.
///
/// Elemento interativo para ações comuns com ícone centrado e feedback visual.
class NutriIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const NutriIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Icon(
              icon,
              color: color ?? AppColors.secondary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
