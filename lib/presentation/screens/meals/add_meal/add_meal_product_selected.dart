import 'package:flutter/material.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Secção exibida no [AddMealScreen] após a seleção de um produto.
///
/// Mostra um cartão com a imagem e o nome do produto, um campo para a
/// quantidade em gramas e a tabela nutricional completa.
/// Se [showChange] for `true`, apresenta um botão "Mudar" que permite
/// trocar o produto selecionado, voltando ao [ProductPicker].
class AddMealProductSelected extends StatelessWidget {
  /// O produto que o utilizador selecionou.
  final Product product;

  /// Controlador ligado ao campo de quantidade (em gramas).
  final TextEditingController servingsController;

  /// Callback invocado quando o utilizador toca no botão "Mudar".
  ///
  /// Normalmente limpa a seleção atual para que o [ProductPicker] volte
  /// a ser exibido. Ignorado se [showChange] for `false`.
  final VoidCallback onChange;

  /// Se `true`, o botão "Mudar" é apresentado no topo da secção.
  ///
  /// Deve ser `false` em modo de edição, onde o produto está bloqueado.
  ///
  /// O valor padrão é `true`.
  final bool showChange;

  /// Cria um [AddMealProductSelected].
  ///
  /// Os parâmetros [product], [servingsController] e [onChange] são
  /// obrigatórios.
  const AddMealProductSelected({
    super.key,
    required this.product,
    required this.servingsController,
    required this.onChange,
    this.showChange = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NutriLabel(
              'PRODUTO',
              variant: NutriLabelVariant.small,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
            if (showChange)
              NutriButton.text(label: 'Mudar', onPressed: onChange),
          ],
        ),
        const SizedBox(height: 8),
        NutriProductCard(product: product),
        const SizedBox(height: 16),
        NutriTextField(
          controller: servingsController,
          label: 'Quantidade (g)',
          hint: '100',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        NutriProductNutritionTable(product: product),
      ],
    );
  }
}