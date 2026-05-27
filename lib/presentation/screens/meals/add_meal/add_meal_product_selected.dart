import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/new/product/product_nutriments.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Section shown on `AddMealScreen` once a [Product] has been picked.
///
/// Displays a compact product card (image + name + brand) with a "Mudar"
/// shortcut to swap the selection, an editable serving-grams field, and the
/// full [ProductNutritionTable] below.
///
/// All meal-form state lives on the parent screen — this widget is purely
/// presentational and reports user input via [servingsController] / [onChange].
class AddMealProductSelected extends StatelessWidget {
  /// Product the user picked. Guaranteed non-null at this point in the flow.
  final Product product;

  /// Controller bound to the serving size (in grams). Owned by the parent.
  final TextEditingController servingsController;

  /// Fired when the user taps "Mudar" to swap to a different product.
  /// Parent should clear its `selectedProduct` so the picker renders again.
  /// Ignored when [showChange] is false.
  final VoidCallback onChange;

  /// Whether the "Mudar" shortcut is rendered. Off in edit mode where the
  /// product is locked to the entry being edited.
  final bool showChange;

  const AddMealProductSelected({
    super.key,
    required this.product,
    required this.servingsController,
    required this.onChange,
    this.showChange = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const NutriLabel(
              'PRODUTO',
              variant: NutriLabelVariant.small,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
            if (showChange)
              NutriButton.text(label: 'Mudar', onPressed: onChange),
          ],
        ),
        const SizedBox(height: 8),
        _ProductCard(product: product),
        const SizedBox(height: 16),
        NutriTextField(
          controller: servingsController,
          label: 'Quantidade (g)',
          hint: '100',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ProductNutritionTable(product: product),
      ],
    );
  }
}


// TODO: Convert this to reusable ProductCard widget that can also be used anywhere.
/// Small surface card showing the product thumbnail, name and brand.
/// Falls back to a generic icon when no image URL is available or the network
/// image fails to load.
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageThumbnailUrl ?? product.imageUrl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Thumbnail(url: imageUrl),
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
                if ((product.brand ?? '').isNotEmpty)
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
    );
  }
}

// TODO: Convert this to a reusable ProductThumbnail widget that can also be used anywhere.
class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
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
              errorBuilder: (_, _, _) => const Icon(
                Icons.image_not_supported,
                color: AppColors.textMuted,
              ),
            )
          : const Icon(Icons.fastfood, color: AppColors.textMuted),
    );
  }
}
