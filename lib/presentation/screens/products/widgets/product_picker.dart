import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';
import 'package:nutri_scan/presentation/screens/products/product_details_screen.dart'
    show productByBarcodeProvider;
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Widget reutilizável para selecionar um [Product] a partir da lista de
/// produtos guardados ou através de um scan.
///
/// Apresenta um campo de pesquisa, um botão para abrir o scanner e uma lista
/// dos produtos guardados que correspondem à pesquisa. Quando o utilizador
/// toca num produto, este é carregado completamente (incluindo nutriments)
/// e devolvido através do callback [onPick].
///
/// Utilizado pelo [AddMealScreen] e por qualquer ecrã que precise de um
/// seletor de produto.
class ProductPicker extends ConsumerStatefulWidget {
  /// Callback invocado quando o utilizador seleciona um produto.
  ///
  /// Recebe o [Product] completo, já com os dados nutricionais.
  final ValueChanged<Product> onPick;

  /// Cria um [ProductPicker].
  ///
  /// O parâmetro [onPick] é obrigatório.
  const ProductPicker({super.key, required this.onPick});

  @override
  ConsumerState<ProductPicker> createState() => _ProductPickerState();
}

/// Estado do [ProductPicker] que gere a pesquisa, a lista de produtos
/// guardados e a navegação para o scanner.
class _ProductPickerState extends ConsumerState<ProductPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carrega o [Product] completo a partir do [barcode] e invoca [onPick].
  ///
  /// Como os produtos guardados são armazenados como snapshots leves
  /// (nome, marca, kcal/100g), é necessário obter o produto completo
  /// (com nutriments) antes de o devolver.
  Future<void> _select(String barcode) async {
    final product = await ref.read(productByBarcodeProvider(barcode).future);
    if (product != null && mounted) widget.onPick(product);
  }

  /// Abre o scanner em modo de seleção.
  ///
  /// O scanner devolve o código de barras lido através de [context.pop].
  /// Em seguida, carrega o produto completo e invoca [onPick].
  Future<void> _openScanner() async {
    final barcode = await context.push<String>('/scanner/pick');
    if (barcode != null && barcode.isNotEmpty) {
      await _select(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final saved = ref.watch(savedProductsProvider).value ?? [];
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? saved
        : saved
              .where(
                (s) =>
                    s.name.toLowerCase().contains(query) ||
                    (s.brand ?? '').toLowerCase().contains(query),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NutriLabel(
          'PRODUTO',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        NutriTextField(
          controller: _searchController,
          label: 'Pesquisar',
          hint: 'Procura nos teus produtos guardados',
          icon: Icons.search,
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        NutriButton.transparent(
          label: 'Fazer scan',
          icon: Icon(
            Icons.qr_code_scanner,
            size: 18,
            color: colorScheme.secondary,
          ),
          onPressed: _openScanner,
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          NutriLabel(
            'Nenhum produto guardado.',
            variant: NutriLabelVariant.small,
            color: colorScheme.onSurfaceVariant,
          )
        else
          ...filtered.map(
            (saved) => NutriProductListItem(
              imageUrl: saved.imageUrl ?? '',
              name: saved.name,
              brand: saved.brand,
              caloriesPer100g: saved.caloriesPer100g,
              onTap: () => _select(saved.barcode),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}