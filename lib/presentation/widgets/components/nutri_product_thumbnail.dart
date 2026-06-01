import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Miniatura quadrada de produto com imagem de rede e ícone de fallback.
///
/// Exibe uma imagem de produto com tamanho customizável e um ícone padrão
/// quando a URL não está disponível ou o carregamento falha.
class NutriProductThumbnail extends StatelessWidget {
  /// URL da imagem do produto.
  ///
  /// Se `null` ou vazia, é exibido o [fallbackIcon].
  final String? url;

  /// Largura e altura da miniatura.
  ///
  /// O valor padrão é 56.
  final double size;

  /// Ícone exibido quando a imagem não está disponível.
  ///
  /// O valor padrão é [Icons.fastfood].
  final IconData fallbackIcon;

  /// Cria uma [NutriProductThumbnail].
  ///
  /// O parâmetro [url] é obrigatório (pode ser `null`).
  const NutriProductThumbnail({
    super.key,
    required this.url,
    this.size = 56,
    this.fallbackIcon = Icons.fastfood,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (url != null && url!.isNotEmpty)
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_not_supported,
                color: colorScheme.onSurfaceVariant,
                size: size * 0.4,
              ),
            )
          : Icon(
              fallbackIcon,
              color: colorScheme.onSurfaceVariant,
              size: size * 0.4,
            ),
    );
  }
}