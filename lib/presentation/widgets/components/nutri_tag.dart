import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Variante de cor para a [NutriTag].
enum NutriTagVariant {
  /// Cor primária da aplicação.
  primary,

  /// Cor secundária da aplicação.
  secondary,

  /// Verde de sucesso.
  success,

  /// Laranja de aviso.
  warning,

  /// Vermelho de erro.
  error,
}

/// Etiqueta (badge) colorida com texto e ícone opcionais.
///
/// Componente para etiquetar, categorizar ou indicar estado.
/// Suporta cinco variantes de cor ([NutriTagVariant]), um ícone à esquerda
/// e um botão de fecho opcional ([onClose]).
class NutriTag extends StatelessWidget {
  /// Texto exibido na etiqueta.
  final String label;

  /// Variante de cor que define o tom da etiqueta.
  ///
  /// O valor padrão é [NutriTagVariant.primary].
  final NutriTagVariant variant;

  /// Callback invocado quando o botão de fecho é pressionado.
  ///
  /// Se `null`, o botão de fecho não é apresentado.
  final VoidCallback? onClose;

  /// Ícone opcional exibido antes do [label].
  final IconData? icon;

  /// Cria uma [NutriTag].
  ///
  /// O parâmetro [label] é obrigatório.
  const NutriTag({
    super.key,
    required this.label,
    this.variant = NutriTagVariant.primary,
    this.onClose,
    this.icon,
  });

  /// Cor de fundo da etiqueta para a variante atual.
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

  /// Cor do texto e ícone da etiqueta para a variante atual.
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