import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_card.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Card compacto para exibição de uma estatística.
///
/// Apresenta um rótulo, um valor de destaque e, opcionalmente, um subvalor,
/// um ícone e uma ação de toque. Ideal para dashboards e painéis de resumo.
class NutriStatCard extends StatelessWidget {
  /// Rótulo da estatística (ex.: "CALORIAS").
  final String label;

  /// Valor principal da estatística (ex.: "1 200").
  final String value;

  /// Texto adicional exibido abaixo do [value].
  final String? subvalue;

  /// Cor do texto do [value].
  ///
  /// Se não for especificada, utiliza [ColorScheme.secondary].
  final Color? valueColor;

  /// Ícone opcional exibido no canto superior direito.
  final IconData? icon;

  /// Callback invocado quando o card é tocado.
  final VoidCallback? onTap;

  /// Cria um [NutriStatCard].
  ///
  /// Os parâmetros [label] e [value] são obrigatórios.
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
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: colorScheme.onSurfaceVariant,
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            NutriLabel(
              value,
              variant: NutriLabelVariant.headline,
              color: valueColor ?? colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
            if (subvalue != null) ...[
              const SizedBox(height: 4),
              NutriLabel(
                subvalue!,
                variant: NutriLabelVariant.small,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}