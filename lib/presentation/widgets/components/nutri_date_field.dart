import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Campo de data clicável com ícone de calendário.
///
/// Exibe uma data formatada num container com estilo de campo de formulário.
/// Ao ser tocado, invoca o callback [onTap] — tipicamente para abrir um
/// seletor de data. A data é apresentada no formato DD/MM/AAAA.
class NutriDateField extends StatelessWidget {
  /// A data atualmente selecionada, exibida no campo.
  final DateTime date;

  /// Callback invocado quando o utilizador toca no campo.
  final VoidCallback onTap;

  /// Texto de sugestão exibido quando a data ainda não foi definida.
  ///
  /// Atualmente não utilizado na renderização, reservado para uso futuro.
  final String? hint;

  /// Cria um [NutriDateField].
  ///
  /// Os parâmetros [date] e [onTap] são obrigatórios.
  const NutriDateField({
    super.key,
    required this.date,
    required this.onTap,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatted = formatDmy(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: colorScheme.secondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            NutriLabel(
              formatted,
              variant: NutriLabelVariant.body,
              color: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}