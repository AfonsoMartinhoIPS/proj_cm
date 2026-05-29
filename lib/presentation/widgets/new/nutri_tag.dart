import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Variante de cor para a [NutriTag].
enum NutriTagVariant { primary, secondary, success, warning, error }

/// Badge/tag customizável com 5 variántes de cor.
///
/// Componente para etiquetar, categorizar ou indicar status.
/// Suporta ícone e botão de fecho opcionais.
class NutriTag extends StatelessWidget {
  final String label;
  final NutriTagVariant variant;
  final VoidCallback? onClose;
  final IconData? icon;

  const NutriTag({
    super.key,
    required this.label,
    this.variant = NutriTagVariant.primary,
    this.onClose,
    this.icon,
  });

  Color _getBackgroundColor() {
    switch (variant) {
      case NutriTagVariant.primary:
        return AppColors.primary.withValues(alpha: 0.1);
      case NutriTagVariant.secondary:
        return AppColors.secondary.withValues(alpha: 0.1);
      case NutriTagVariant.success:
        return Colors.green.withValues(alpha: 0.1);
      case NutriTagVariant.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case NutriTagVariant.error:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case NutriTagVariant.primary:
        return AppColors.primary;
      case NutriTagVariant.secondary:
        return AppColors.secondary;
      case NutriTagVariant.success:
        return Colors.green;
      case NutriTagVariant.warning:
        return Colors.orange;
      case NutriTagVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          NutriLabel(
            label,
            variant: NutriLabelVariant.small,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          if (onClose != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 14, color: textColor),
            ),
          ],
        ],
      ),
    );
  }
}
