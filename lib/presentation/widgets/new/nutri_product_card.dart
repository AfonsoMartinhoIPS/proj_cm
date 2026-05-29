import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_product_thumbnail.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_card.dart';

/// Componente que exibe um produto com imagem, nome, marca e nutrientes opcionais.
///
/// Utilize [NutriProductCard] para mostrar informações de um produto de forma compacta
/// e visual em listas, buscas ou seleções de produtos.
class NutriProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showBrand;
  final bool showNutrients;

  const NutriProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showBrand = true,
    this.showNutrients = false,
  });

  @override
  Widget build(BuildContext context) {
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
                        color: AppColors.onBackground,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showBrand && (product.brand ?? '').isNotEmpty)
                        NutriLabel(
                          product.brand!,
                          variant: NutriLabelVariant.small,
                          color: AppColors.textMuted,
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
                  _nutrientInfo('Kcal', product.nutriments.caloriesPer100g?.toStringAsFixed(0) ?? "0"),
                  _nutrientInfo('Prot.', '${product.nutriments.proteinPer100g?.toStringAsFixed(1) ?? "0"}g'),
                  _nutrientInfo('Carbs', '${product.nutriments.carbsPer100g?.toStringAsFixed(1) ?? "0"}g'),
                  _nutrientInfo('Gord.', '${product.nutriments.fatPer100g?.toStringAsFixed(1) ?? "0"}g'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nutrientInfo(String label, String value) {
    return Column(
      children: [
        NutriLabel(
          label,
          variant: NutriLabelVariant.small,
          color: AppColors.textMuted,
        ),
        NutriLabel(
          value,
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
      ],
    );
  }
}
