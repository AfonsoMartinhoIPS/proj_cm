import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Section shown on `AddMealScreen` once a [Product] has been picked.
///
/// Displays a compact product card (image + name + brand) with a "Mudar"
/// shortcut to swap the selection, an editable serving-grams field, and the
/// full [NutriProductNutritionTable] below.
///
/// All meal-form state lives on the parent screen - this widget is purely
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
        NutriProductCard(product: product),
        const SizedBox(height: 16),
        NutriTextField(
          controller: servingsController,
          label: 'Quantidade (g)',
          hint: '100',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        NutriProductNutritionTable(product: product),
      ],
    );
  }
}
