import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Avatar circular com iniciais ou imagem.
///
/// Exibe um avatar redondo com iniciais fallback, imagem de rede com fallback
/// a iniciais, e cores customizáveis.
class NutriCircleAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final String? imageUrl;

  const NutriCircleAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => NutriLabel(
                initials,
                variant: NutriLabelVariant.small,
                color: textColor ?? AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            )
          : NutriLabel(
              initials,
              variant: NutriLabelVariant.small,
              color: textColor ?? AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
    );
  }
}
