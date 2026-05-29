import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Botão circular com ícone, borda e cores customizáveis.
///
/// Elemento interativo redondo para ações de navegação ou controlo,
/// como botões de perfil ou ações flutuantes.
class NutriCircularAvatarButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;

  const NutriCircularAvatarButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? AppColors.surface,
          border: Border.all(
            color: borderColor ?? AppColors.primary,
            width: borderWidth,
          ),
        ),
        child: Icon(
          icon,
          color: foregroundColor ?? AppColors.onBackground,
        ),
      ),
    );
  }
}
