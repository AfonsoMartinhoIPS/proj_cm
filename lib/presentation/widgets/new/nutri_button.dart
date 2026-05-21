import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Define as variantes visuais disponíveis para o [NutriButton].
enum NutriButtonVariant { primary, transparent, text }

/// Um botão customizado e adaptável para o ecossistema NutriScan.
/// 
/// Suporta três variantes visuais ([primary], [transparent], e [text]), estados
/// de carregamento incorporados, suporte a ícones e textos secundários com ênfase estilizada.
class NutriButton extends StatelessWidget {
  /// O texto principal exibido no centro do botão.
  final String label;

  /// Um texto opcional exibido à direita do [label] com uma espessura de fonte superior.
  final String secondaryLabel;

  /// Ação disparada ao pressionar o botão. Se for `null`, o botão entra em estado desativado.
  final VoidCallback? onPressed;

  /// Controla o aspeto visual e o comportamento de dimensionamento do botão.
  final NutriButtonVariant variant;

  /// Quando `true`, desativa a interação e exibe um indicador de progresso circular.
  final bool isLoading;

  /// Um widget opcional (geralmente um [Icon]) exibido antes do [label].
  final Widget? icon;

  /// Tamanho customizado da fonte para os textos do botão.
  final double? fontSize;

  /// Construtor padrão que cria a variante **Primary** do botão.
  /// 
  /// Esta variante possui uma cor de fundo sólida preenchida com [AppColors.primary]
  /// e expande-se por padrão para ocupar a largura máxima disponível.
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

  /// Construtor alternativo para a variante **Transparent** (Outline).
  /// 
  /// Renderiza um botão com fundo transparente, contorno definido pela cor
  /// [AppColors.secondary] e largura total.
  const NutriButton.transparent({
    super.key,
    required this.label,
    this.secondaryLabel = "",
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize,
  }) : variant = NutriButtonVariant.transparent;

  /// Construtor alternativo para a variante **Text**.
  /// 
  /// Remove as restrições de altura, bordas e largura total, comportando-se como
  /// um link de texto simples com uma área de toque otimizada.
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
    final isTransparent = variant == NutriButtonVariant.transparent;
    final isTextVariant = variant == NutriButtonVariant.text;
    final isEnabled = onPressed != null && !isLoading;
    
    Color baseColor;
    Color backgroundColor;

    if (!isEnabled) {
      baseColor = isLoading 
          ? ((isTransparent || isTextVariant) ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.onBackground.withValues(alpha: 0.5))
          : Colors.grey.shade500;
          
      backgroundColor = (isTransparent || isTextVariant)
          ? Colors.transparent 
          : (isLoading ? AppColors.primary.withValues(alpha: 0.7) : Colors.grey.shade300);
    } else {
      baseColor = (isTransparent || isTextVariant) ? AppColors.secondary : AppColors.onBackground;
      backgroundColor = (isTransparent || isTextVariant) ? Colors.transparent : AppColors.primary;
    }
    
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontFamily: 'DM Sans',
          letterSpacing: 0.60,
          fontSize: fontSize ?? 16,
          color: baseColor,
        );

    return Container(
      width: isTextVariant ? null : double.infinity,
      height: isTextVariant ? null : 45,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: isTransparent 
            ? Border.all(color: isEnabled ? AppColors.secondary : Colors.grey.shade400, width: 2.0) 
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd - (isTransparent ? 2 : 0)),
          overlayColor: WidgetStateProperty.all(baseColor.withValues(alpha: 0.1)),
          child: Padding(
            padding: isTextVariant ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : EdgeInsets.zero,
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
                        Text(
                          label,
                          style: textStyle?.copyWith(fontWeight: isTextVariant ? FontWeight.w600 : FontWeight.w500),
                        ),
                        if (secondaryLabel.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            secondaryLabel, 
                            style: textStyle?.copyWith(fontWeight: FontWeight.w900),
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