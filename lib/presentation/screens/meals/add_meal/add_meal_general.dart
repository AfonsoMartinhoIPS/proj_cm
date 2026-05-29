import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Top section of `AddMealScreen` showing the two pieces of metadata that
/// don't depend on a specific product: which meal of the day the entry is
/// for, and on which date it was eaten.
///
/// Stateless - all values live on the parent screen and are pushed in via
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
        NutriChipSelector(
          items: MealType.values,
          selected: mealType,
          onChanged: onMealTypeChanged,
          label: (mealType) => mealType.label,
        ),
        const SizedBox(height: 20),
        const NutriLabel(
          'DATA',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 8),
        NutriDateField(date: date, onTap: () => _pickDate(context)),
      ],
    );
  }
}
