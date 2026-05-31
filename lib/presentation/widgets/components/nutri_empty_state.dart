import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_button.dart';

/// Estado vazio centrado para ecrãs sem dados.
///
/// Exibe um ícone (ou widget customizado), um título, um subtítulo opcional
/// e um botão de ação opcional. Ideal para listas vazias, pesquisas sem
/// resultados ou estados iniciais.
class NutriEmptyState extends StatelessWidget {
  /// O título principal exibido abaixo do ícone.
  final String title;

  /// Texto descritivo opcional exibido abaixo do título.
  final String? subtitle;

  /// Ícone grande exibido no topo do estado vazio.
  ///
  /// Ignorado se [customIcon] for fornecido.
  final IconData? icon;

  /// Rótulo do botão de ação.
  ///
  /// Se for `null`, o botão não é renderizado.
  final String? actionLabel;

  /// Callback invocado quando o botão de ação é pressionado.
  ///
  /// Ignorado se [actionLabel] for `null`.
  final VoidCallback? onAction;

  /// Widget customizado para substituir o ícone padrão.
  ///
  /// Tem prioridade sobre [icon].
  final Widget? customIcon;

  /// Cria um [NutriEmptyState].
  ///
  /// O parâmetro [title] é obrigatório.
  const NutriEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            if (icon != null || customIcon != null) const SizedBox(height: 16),
            NutriLabel(
              title,
              variant: NutriLabelVariant.headline,
              textAlign: TextAlign.center,
              color: colorScheme.onSurface,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              NutriLabel(
                subtitle!,
                variant: NutriLabelVariant.body,
                textAlign: TextAlign.center,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: NutriButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}