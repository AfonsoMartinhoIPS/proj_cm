import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_card.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Card compacto para exibir estatísticas com valor principal e subvalor.
///
/// Componente para dashboards e painéis de resumo de dados,
/// com suporte a ícone customizado e cores específicas.
class NutriStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subvalue;
  final Color? valueColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const NutriStatCard({
    super.key,
    required this.label,
    required this.value,
    this.subvalue,
    this.valueColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NutriCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutriLabel(
                  label.toUpperCase(),
                  variant: NutriLabelVariant.small,
                  color: AppColors.textMuted,
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: AppColors.secondary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            NutriLabel(
              value,
              variant: NutriLabelVariant.headline,
              color: valueColor ?? AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
            if (subvalue != null) ...[
              const SizedBox(height: 4),
              NutriLabel(
                subvalue!,
                variant: NutriLabelVariant.small,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
