import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Miniatura quadrada de produto com imagem em rede e ícone de fallback.
///
/// Exibe uma imagem de produto com tamanho customizável e um ícone padrão
/// quando a URL não está disponível ou o carregamento falha.
class NutriProductThumbnail extends StatelessWidget {
  final String? url;
  final double size;
  final IconData fallbackIcon;

  const NutriProductThumbnail({
    super.key,
    required this.url,
    this.size = 56,
    this.fallbackIcon = Icons.fastfood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (url != null && url!.isNotEmpty)
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_not_supported,
                color: AppColors.textMuted,
                size: size * 0.4,
              ),
            )
          : Icon(
              fallbackIcon,
              color: AppColors.textMuted,
              size: size * 0.4,
            ),
    );
  }
}
