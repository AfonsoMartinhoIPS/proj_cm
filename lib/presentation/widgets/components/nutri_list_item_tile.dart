import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Item de lista genérico com suporte a ícone, título, subtítulo e ações.
///
/// Apresenta uma linha clicável com um [leading] (ícone ou widget), um título
/// obrigatório, um subtítulo opcional e um widget à direita ([trailing]) ou,
/// alternativamente, um botão de eliminação ([onDelete]).
class NutriListItemTile extends StatelessWidget {
  /// O texto principal do item.
  final String title;

  /// Texto secundário exibido abaixo do [title].
  final String? subtitle;

  /// Ícone a ser mostrado no início do item, caso [leading] seja `null`.
  final IconData? leadingIcon;

  /// Widget customizado para o início do item. Tem prioridade sobre [leadingIcon].
  final Widget? leading;

  /// Widget exibido no final do item. Ignorado se [onDelete] for fornecida.
  final Widget? trailing;

  /// Callback invocado quando o utilizador toca no item.
  final VoidCallback? onTap;

  /// Callback invocado quando o utilizador toca no botão de eliminação.
  ///
  /// Se fornecido, um ícone de caixote do lixo é apresentado no final do item
  /// em vez de [trailing].
  final VoidCallback? onDelete;

  /// Cria um [NutriListItemTile].
  ///
  /// O parâmetro [title] é obrigatório.
  const NutriListItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (leading != null)
              leading!
            else if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    title,
                    variant: NutriLabelVariant.body,
                    color: colorScheme.onSurface,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    NutriLabel(
                      subtitle!,
                      variant: NutriLabelVariant.small,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}