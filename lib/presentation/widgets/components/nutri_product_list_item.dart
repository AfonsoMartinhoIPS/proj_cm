import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Item de lista para apresentação resumida de um produto.
///
/// Exibe a miniatura do produto, o nome, a marca (opcional), as calorias
/// por 100 g (opcional) e um widget à direita ([trailing]).
/// Suporta toque através de [onTap].
class NutriProductListItem extends StatelessWidget {
  /// URL da imagem do produto.
  final String imageUrl;

  /// Nome do produto.
  final String name;

  /// Marca do produto (opcional).
  final String? brand;

  /// Calorias por 100 g (opcional).
  final double? caloriesPer100g;

  /// Callback invocado quando o item é tocado.
  final VoidCallback? onTap;

  /// Widget opcional exibido no final do item.
  final Widget? trailing;

  /// Cria um [NutriProductListItem].
  ///
  /// Os parâmetros [imageUrl] e [name] são obrigatórios.
  const NutriProductListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    this.brand,
    this.caloriesPer100g,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                NutriProductThumbnail(url: imageUrl, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutriLabel(
                        name,
                        variant: NutriLabelVariant.body,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      if (brand != null)
                        NutriLabel(
                          brand!,
                          variant: NutriLabelVariant.small,
                          color: colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
                if (caloriesPer100g != null)
                  NutriLabel(
                    '${caloriesPer100g!.toStringAsFixed(0)} kcal',
                    variant: NutriLabelVariant.small,
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}