import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Avatar circular com iniciais ou imagem de rede.
///
/// Exibe um círculo com as iniciais fornecidas por [initials].
/// Se [imageUrl] for fornecida, tenta carregar a imagem; caso ocorra um erro
/// ou a URL esteja vazia, exibe as iniciais como fallback.
///
/// As cores de fundo e texto podem ser personalizadas; caso contrário,
/// utilizam as cores do tema atual.
class NutriCircleAvatar extends StatelessWidget {
  /// As iniciais a exibir quando não há imagem disponível.
  final String initials;

  /// O diâmetro do avatar.
  ///
  /// O valor padrão é 40.
  final double size;

  /// Cor de fundo do avatar.
  ///
  /// Se não for especificada, utiliza [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Cor do texto das iniciais.
  ///
  /// Se não for especificada, utiliza [ColorScheme.primary].
  final Color? textColor;

  /// URL da imagem de rede a exibir.
  ///
  /// Se `null` ou ocorrer um erro no carregamento, as iniciais são mostradas.
  final String? imageUrl;

  /// Cria um [NutriCircleAvatar].
  ///
  /// O parâmetro [initials] é obrigatório.
  const NutriCircleAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outline),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => NutriLabel(
                initials,
                variant: NutriLabelVariant.small,
                color: textColor ?? colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          : NutriLabel(
              initials,
              variant: NutriLabelVariant.small,
              color: textColor ?? colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
    );
  }
}