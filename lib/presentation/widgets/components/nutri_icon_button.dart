import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Botão de ícone com fundo, borda e estilo customizável.
///
/// Exibe um ícone dentro de um container retangular com cantos arredondados,
/// borda e cor de fundo configuráveis. Ideal para ações secundárias
/// que precisam de um toque visual mais destacado do que um simples [IconButton].
class NutriIconButton extends StatelessWidget {
  /// O ícone a ser exibido no centro do botão.
  final IconData icon;

  /// Callback chamado quando o botão é pressionado.
  final VoidCallback onPressed;

  /// Cor do ícone.
  ///
  /// Se não for especificada, utiliza [ColorScheme.secondary].
  final Color? color;

  /// Cor de fundo do botão.
  ///
  /// Se não for especificada, utiliza [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Largura e altura do botão.
  ///
  /// O valor padrão é 44.
  final double size;

  /// Tamanho do ícone.
  ///
  /// O valor padrão é 20.
  final double iconSize;

  /// Texto de dica de contexto exibido ao pressionar longamente.
  final String? tooltip;

  /// Cria um [NutriIconButton].
  ///
  /// Os parâmetros [icon] e [onPressed] são obrigatórios.
  const NutriIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Icon(
              icon,
              color: color ?? colorScheme.secondary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}