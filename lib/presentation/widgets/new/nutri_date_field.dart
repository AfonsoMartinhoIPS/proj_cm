import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Campo de data clicável com ícone de calendário.
///
/// Entrada visual para seleção de data. Dispara callback ao clicar
/// para abrir picker ou validador de data.
class NutriDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final String? hint;

  const NutriDateField({
    super.key,
    required this.date,
    required this.onTap,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = formatDmy(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
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
