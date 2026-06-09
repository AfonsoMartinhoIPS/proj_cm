import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Linha individual de uma entrada de refeição, usada em listas.
///
/// Exibe a miniatura do produto, o nome, a quantidade em gramas e as calorias.
/// Ao ser tocada, invoca o callback [onEdit]. O ícone de apagar no final
/// dispara o callback [onDelete].
class MealEntryTile extends StatelessWidget {
  /// A entrada de refeição cujos dados serão exibidos.
  final MealEntry entry;

  /// Callback invocado quando o utilizador toca na linha (editar).
  final VoidCallback onEdit;

  /// Callback invocado quando o utilizador toca no ícone de apagar.
  final VoidCallback onDelete;

  /// Cria um [MealEntryTile].
  ///
  /// Os parâmetros [entry], [onEdit] e [onDelete] são obrigatórios.
  const MealEntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grams = entry.servingGrams.toStringAsFixed(0);
    final kcal = entry.calories.toStringAsFixed(0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              NutriProductThumbnail(
                url: entry.productImageUrl,
                size: 40,
                fallbackIcon: Icons.fastfood,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NutriLabel(
                      entry.productName,
                      variant: NutriLabelVariant.body,
                      color: colorScheme.onSurface,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    NutriLabel(
                      '${grams}g',
                      variant: NutriLabelVariant.small,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NutriLabel(
                '$kcal kcal',
                variant: NutriLabelVariant.small,
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: colorScheme.onSurfaceVariant,
                tooltip: 'Apagar',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}