import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Single-entry row used inside [DayDetailScreen].
///
/// Thumbnail + product name + serving grams on the left, kcal on the right,
/// trailing delete button. Whole row is tappable → [onEdit].
class MealEntryTile extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MealEntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final url = entry.productImageUrl;
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: (url != null && url.isNotEmpty)
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.fastfood,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NutriLabel(
                      entry.productName,
                      variant: NutriLabelVariant.body,
                      color: AppColors.onBackground,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    NutriLabel(
                      '${grams}g',
                      variant: NutriLabelVariant.small,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NutriLabel(
                '$kcal kcal',
                variant: NutriLabelVariant.small,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.textMuted,
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
