import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Top section of `AddMealScreen` showing the two pieces of metadata that
/// don't depend on a specific product: which meal of the day the entry is
/// for, and on which date it was eaten.
///
/// Stateless — all values live on the parent screen and are pushed in via
/// [mealType] and [date]. User input bubbles back through [onMealTypeChanged]
/// and [onDateChanged].
class AddMealGeneralInfo extends StatelessWidget {
  /// Currently selected meal type. Highlighted chip in the picker row.
  final MealType mealType;

  /// Date the meal was consumed. Defaults to "today" on the parent screen.
  final DateTime date;

  /// Fired when the user taps a different meal type chip.
  final ValueChanged<MealType> onMealTypeChanged;

  /// Fired when the user picks a new date in the date picker dialog.
  final ValueChanged<DateTime> onDateChanged;

  const AddMealGeneralInfo({
    super.key,
    required this.mealType,
    required this.date,
    required this.onMealTypeChanged,
    required this.onDateChanged,
  });

  /// Opens the platform date picker. Restricted to the last 365 days so
  /// users can backfill recent meals but not log into the future.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutriLabel(
          'TIPO DE REFEIÇÃO',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 8),
        _MealTypeChips(selected: mealType, onChanged: onMealTypeChanged),
        const SizedBox(height: 20),
        const NutriLabel(
          'DATA',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 8),
        _DateField(date: date, onTap: () => _pickDate(context)),
      ],
    );
  }
}

/// Row of selectable chips, one per [MealType]. The selected chip is filled
/// with [AppColors.primary]; unselected chips show the muted surface tone.
class _MealTypeChips extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  const _MealTypeChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MealType.values.map((mealType) {
        final isSelected = mealType == selected;
        return GestureDetector(
          onTap: () => onChanged(mealType),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: NutriLabel(
              mealType.label,
              variant: NutriLabelVariant.small,
              color: isSelected
                  ? AppColors.onBackground
                  : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Tappable surface displaying the current date as DD/MM/YYYY. Tapping it
/// triggers the parent-provided [onTap] callback (which opens the date picker).
class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted = formatDmy(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // TODO: replace with NutriCard widget
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.secondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            NutriLabel(
              formatted,
              variant: NutriLabelVariant.body,
              color: AppColors.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
