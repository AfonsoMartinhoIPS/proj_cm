import 'package:flutter/material.dart';

/// Botão circular com ícone, borda e cores customizáveis.
///
/// Elemento interativo redondo para ações de navegação ou controlo.
/// Todas as cores são opcionais e, quando omitidas, herdam os valores
/// do tema atual através do [ColorScheme].
class NutriCircularAvatarButton extends StatelessWidget {
  /// Callback invocado quando o botão é pressionado.
  final VoidCallback onTap;

  /// O ícone exibido no centro do botão.
  final IconData icon;

  /// O diâmetro do botão.
  ///
  /// O valor padrão é 40.
  final double size;

  /// Cor de fundo do botão.
  ///
  /// Se não for especificada, utiliza [ColorScheme.surface].
  final Color? backgroundColor;

  /// Cor do ícone.
  ///
  /// Se não for especificada, utiliza [ColorScheme.onSurface].
  final Color? foregroundColor;

  /// Cor da borda do botão.
  ///
  /// Se não for especificada, utiliza [ColorScheme.primary].
  final Color? borderColor;

  /// Espessura da borda do botão.
  ///
  /// O valor padrão é 2.
  final double borderWidth;

  /// Cria um [NutriCircularAvatarButton].
  ///
  /// Os parâmetros [onTap] e [icon] são obrigatórios.
  const NutriCircularAvatarButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? colorScheme.surface,
          border: Border.all(
            color: borderColor ?? colorScheme.primary,
            width: borderWidth,
          ),
        ),
        child: Icon(
          icon,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
    );
  }
}