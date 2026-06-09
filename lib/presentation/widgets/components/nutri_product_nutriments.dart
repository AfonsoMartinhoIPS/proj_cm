import 'package:flutter/material.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Tabela nutricional para 100 g / 100 ml de um produto.
///
/// Exibe os valores nutricionais do [product] num container estilizado,
/// com destaque para calorias, macronutrientes e sal.
class NutriProductNutritionTable extends StatelessWidget {
  /// O produto cuja informação nutricional será exibida.
  final Product product;

  /// Cria uma [NutriProductNutritionTable].
  ///
  /// O parâmetro [product] é obrigatório.
  const NutriProductNutritionTable({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    Nutriments nutriments = product.nutriments;

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutriLabel(
            'POR 100G / 100ML',
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          _row('Calorias', nutriments.caloriesPer100g, 'kcal', colorScheme),
          _row('Proteína', nutriments.proteinPer100g, 'g', colorScheme),
          _row('Hidratos', nutriments.carbsPer100g, 'g', colorScheme),
          _row('  dos quais açúcares', nutriments.sugarsPer100g, 'g', colorScheme),
          _row('Gordura', nutriments.fatPer100g, 'g', colorScheme),
          _row('  das quais saturadas', nutriments.saturatedFatPer100g, 'g', colorScheme),
          _row('Fibra', nutriments.fiberPer100g, 'g', colorScheme),
          _row('Sal', nutriments.saltPer100g, 'g', colorScheme),
        ],
      ),
    );
  }

  /// Constrói uma linha da tabela nutricional.
  ///
  /// Exibe o [label] do nutriente à esquerda e o respetivo [value] com a
  /// [unit] à direita. Se [value] for `null`, é apresentado um traço.
  Widget _row(String label, double? value, String unit, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NutriLabel(
            label,
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
          ),
          NutriLabel(
            value != null ? '${value.toStringAsFixed(1)} $unit' : '- $unit',
            variant: NutriLabelVariant.small,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}