import 'package:flutter/material.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_product_thumbnail.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_card.dart';

/// Componente que exibe um produto com imagem, nome, marca e nutrientes opcionais.
///
/// Utilize [NutriProductCard] para mostrar informações de um produto de forma compacta
/// e visual em listas, buscas ou seleções de produtos.
class NutriProductCard extends StatelessWidget {
  /// O produto cujos dados serão exibidos.
  final Product product;

  /// Callback invocado quando o utilizador toca no card.
  final VoidCallback? onTap;

  /// Se `true`, exibe a marca do produto abaixo do nome.
  ///
  /// O valor padrão é `true`.
  final bool showBrand;

  /// Se `true`, exibe uma linha com os principais nutrientes do produto.
  ///
  /// O valor padrão é `false`.
  final bool showNutrients;

  /// Cria um [NutriProductCard].
  ///
  /// O parâmetro [product] é obrigatório.
  const NutriProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showBrand = true,
    this.showNutrients = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: NutriCard(
        child: Column(
          children: [
            Row(
              children: [
                NutriProductThumbnail(
                  url: product.imageThumbnailUrl ?? product.imageUrl,
                  size: 56,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutriLabel(
                        product.name,
                        variant: NutriLabelVariant.body,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showBrand && (product.brand ?? '').isNotEmpty)
                        NutriLabel(
                          product.brand!,
                          variant: NutriLabelVariant.small,
                          color: colorScheme.onSurfaceVariant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (showNutrients) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _nutrientInfo('Kcal', product.nutriments.caloriesPer100g?.toStringAsFixed(0) ?? "0", colorScheme),
                  _nutrientInfo('Prot.', '${product.nutriments.proteinPer100g?.toStringAsFixed(1) ?? "0"}g', colorScheme),
                  _nutrientInfo('Carbs', '${product.nutriments.carbsPer100g?.toStringAsFixed(1) ?? "0"}g', colorScheme),
                  _nutrientInfo('Gord.', '${product.nutriments.fatPer100g?.toStringAsFixed(1) ?? "0"}g', colorScheme),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói a célula de informação de um nutriente específico.
  ///
  /// Exibe o [label] (ex.: "Kcal") e o [value] correspondente (ex.: "250").
  Widget _nutrientInfo(String label, String value, ColorScheme colorScheme) {
    return Column(
      children: [
        NutriLabel(
          label,
          variant: NutriLabelVariant.small,
          color: colorScheme.onSurfaceVariant,
        ),
        NutriLabel(
          value,
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ],
    );
  }
}