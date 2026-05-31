import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Variantes visuais do [NutriButton].
enum NutriButtonVariant {
  /// Botão com fundo preenchido e texto branco.
  primary,

  /// Botão com fundo transparente e contorno.
  transparent,

  /// Botão de texto simples, sem fundo nem contorno.
  text,
}

/// Botão customizado com três variantes visuais.
///
/// Suporta estado de carregamento, ícone à esquerda do texto e um rótulo
/// secundário com ênfase visual. Adapta automaticamente as cores ao tema
/// atual através do [ColorScheme].
class NutriButton extends StatelessWidget {
  /// O texto principal exibido no centro do botão.
  final String label;

  /// Texto adicional exibido à direita do [label] com peso de fonte superior.
  final String secondaryLabel;

  /// Ação disparada ao pressionar o botão.
  ///
  /// Quando `null` ou durante o estado de carregamento, o botão fica
  /// visualmente desativado.
  final VoidCallback? onPressed;

  /// A variante visual do botão.
  ///
  /// O valor padrão é [NutriButtonVariant.primary].
  final NutriButtonVariant variant;

  /// Se `true`, desativa a interação e exibe um [CircularProgressIndicator].
  final bool isLoading;

  /// Widget opcional exibido antes do [label] (geralmente um [Icon]).
  final Widget? icon;

  /// Tamanho da fonte do texto do botão.
  ///
  /// Se não for especificado, utiliza o tamanho definido pela variante ou
  /// pelo tema.
  final double? fontSize;

  /// Cria um [NutriButton] com a variante [NutriButtonVariant.primary].
  ///
  /// O botão expande-se para ocupar a largura máxima disponível e utiliza
  /// a cor primária do tema como fundo.
  const NutriButton({
    super.key,
    required this.label,
    this.secondaryLabel = "",
    required this.onPressed,
    this.variant = NutriButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fontSize,
  });

  /// Cria um [NutriButton] com a variante [NutriButtonVariant.transparent].
  ///
  /// O botão tem fundo transparente, contorno definido pela cor secundária
  /// do tema e largura total.
  const NutriButton.transparent({
    super.key,
    required this.label,
    this.secondaryLabel = "",
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize,
  }) : variant = NutriButtonVariant.transparent;

  /// Cria um [NutriButton] com a variante [NutriButtonVariant.text].
  ///
  /// Remove as restrições de altura, bordas e largura total, comportando-se
  /// como um link de texto com área de toque reduzida.
  const NutriButton.text({
    super.key,
    required this.label,
    this.secondaryLabel = "",
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize = 12,
  }) : variant = NutriButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTransparent = variant == NutriButtonVariant.transparent;
    final isTextVariant = variant == NutriButtonVariant.text;
    final isEnabled = onPressed != null && !isLoading;

    Color baseColor;
    Color backgroundColor;

    if (!isEnabled) {
      baseColor = isLoading
          ? ((isTransparent || isTextVariant)
              ? colorScheme.secondary.withValues(alpha: 0.5)
              : colorScheme.onSurface.withValues(alpha: 0.5))
          : colorScheme.onSurface.withValues(alpha: 0.38);

      backgroundColor = (isTransparent || isTextVariant)
          ? Colors.transparent
          : (isLoading
              ? colorScheme.primary.withValues(alpha: 0.7)
              : colorScheme.surfaceContainerHighest);
    } else {
      baseColor = (isTransparent || isTextVariant)
          ? colorScheme.secondary
          : colorScheme.onPrimary;
      backgroundColor = (isTransparent || isTextVariant)
          ? Colors.transparent
          : colorScheme.primary;
    }

    return Container(
      width: isTextVariant ? null : double.infinity,
      height: isTextVariant ? null : 45,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: isTransparent
            ? Border.all(
                color: isEnabled
                    ? colorScheme.secondary
                    : colorScheme.onSurface.withValues(alpha: 0.12),
                width: 2.0,
              )
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius:
              BorderRadius.circular(AppSizes.radiusMd - (isTransparent ? 2 : 0)),
          overlayColor: WidgetStateProperty.all(
            baseColor.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: isTextVariant
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                : EdgeInsets.zero,
            child: Center(
              widthFactor: isTextVariant ? 1.0 : null,
              heightFactor: isTextVariant ? 1.0 : null,
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 10),
                        ],
                        NutriLabel(
                          label,
                          variant: NutriLabelVariant.label,
                          color: baseColor,
                          fontWeight:
                              isTextVariant ? FontWeight.w600 : FontWeight.w500,
                        ),
                        if (secondaryLabel.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          NutriLabel(
                            secondaryLabel,
                            variant: NutriLabelVariant.label,
                            color: baseColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w900,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}