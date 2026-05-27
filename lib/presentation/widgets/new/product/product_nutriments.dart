

import 'package:flutter/material.dart';
import 'package:nutri_scan/core/constants/app_colors.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

class ProductNutritionTable extends StatelessWidget {

  
  final Product product;
  ProductNutritionTable({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    Nutriments nutriments = product.nutriments;

    return Container(
      
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NutriLabel(
            'POR 100G / 100ML',
            color: AppColors.textMuted,
            variant: NutriLabelVariant.small,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
          
          const SizedBox(height: 12),
          _row('Calorias', nutriments.caloriesPer100g, 'kcal'),
          _row('Proteína', nutriments.proteinPer100g, 'g'),
          _row('Hidratos', nutriments.carbsPer100g, 'g'),
          _row('  dos quais açúcares', nutriments.sugarsPer100g, 'g'),
          _row('Gordura', nutriments.fatPer100g, 'g'),
          _row('  das quais saturadas', nutriments.saturatedFatPer100g, 'g'),
          _row('Fibra', nutriments.fiberPer100g, 'g'),
          _row('Sal', nutriments.saltPer100g, 'g'),
        ],
      ),
    );
  }

  Widget _row(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NutriLabel( 
            label,
            color: AppColors.textMuted, variant: NutriLabelVariant.small),
          NutriLabel( 
            value != null ? '${value.toStringAsFixed(1)} $unit' : '- $unit',
              variant: NutriLabelVariant.small,
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}