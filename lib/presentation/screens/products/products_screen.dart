import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';

/// Ecrã que lista os produtos guardados pelo utilizador.
///
/// Permite pesquisar entre os produtos guardados, aceder aos detalhes de cada
/// um e iniciar um scan para adicionar um novo produto. Quando a lista está
/// vazia ou a pesquisa não devolve resultados, apresenta um estado vazio
/// com ações adequadas.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

/// Estado do [ProductsScreen] que gere a pesquisa e a lista de produtos.
class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra a lista de produtos com base na [query] de pesquisa.
  ///
  /// A pesquisa é feita de forma insensível a maiúsculas/minúsculas sobre os
  /// campos `name` e `brand` de cada [SavedProduct].
  List<SavedProduct> _filter(List<SavedProduct> all) {
    if (_query.trim().isEmpty) return all;
    final q = _query.trim().toLowerCase();
    return all.where((savedProduct) {
      final name = savedProduct.name.toLowerCase();
      final brand = (savedProduct.brand ?? '').toLowerCase();
      return name.contains(q) || brand.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncSaved = ref.watch(savedProductsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(
        showBackButton: false,
        title: 'Produtos',
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => context.push('/scan'),
        tooltip: 'Adicionar produto',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: NutriTextField(
                controller: _searchController,
                label: 'Pesquisar',
                hint: 'Pesquisar produtos guardados',
                icon: Icons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: asyncSaved.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NutriLabel(
                          'Erro ao carregar produtos: $e',
                          textAlign: TextAlign.center,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 180,
                          child: NutriButton.transparent(
                            label: 'Tentar novamente',
                            icon: Icon(
                              Icons.refresh,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            onPressed: () =>
                                ref.invalidate(savedProductsProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (savedProducts) {
                  final filtered = _filter(savedProducts);

                  if (filtered.isEmpty) {
                    final hasQuery = _query.isNotEmpty;
                    return NutriEmptyState(
                      icon: null,
                      title: hasQuery
                          ? 'Nenhum produto encontrado para "$_query".'
                          : 'Ainda não guardaste nenhum produto.',
                      subtitle: hasQuery
                          ? 'Tenta outra pesquisa.'
                          : 'Faz o teu primeiro scan.',
                      actionLabel:
                          hasQuery ? 'Limpar pesquisa' : 'Faz o teu 1º scan',
                      onAction: () {
                        if (hasQuery) {
                          _searchController.clear();
                          setState(() => _query = '');
                        } else {
                          context.push('/scan');
                        }
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final savedProduct = filtered[index];
                      return _ProductRow(
                        savedProduct: savedProduct,
                        onTap: () =>
                            context.push('/products/${savedProduct.barcode}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de produto na lista de produtos guardados.
///
/// Exibe a miniatura do produto, o nome, a marca (se disponível) e as
/// calorias por 100 g (se disponível). Ao ser tocada, navega para o ecrã
/// de detalhes do produto.
class _ProductRow extends StatelessWidget {
  /// O produto guardado cujos dados serão exibidos.
  final SavedProduct savedProduct;

  /// Callback invocado quando o utilizador toca na linha.
  final VoidCallback onTap;

  /// Cria uma [_ProductRow].
  ///
  /// Os parâmetros [savedProduct] e [onTap] são obrigatórios.
  const _ProductRow({required this.savedProduct, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NutriCard(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Row(
              children: [
                NutriProductThumbnail(
                  url: savedProduct.imageUrl,
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutriLabel(
                        savedProduct.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        color: colorScheme.onSurface,
                        variant: NutriLabelVariant.body,
                        fontWeight: FontWeight.w600,
                      ),
                      if ((savedProduct.brand ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        NutriLabel(
                          savedProduct.brand!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: colorScheme.onSurfaceVariant,
                          variant: NutriLabelVariant.body,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                NutriLabel(
                  savedProduct.caloriesPer100g != null
                      ? '${savedProduct.caloriesPer100g!.toStringAsFixed(0)} kcal'
                      : '- kcal',
                  color: colorScheme.secondary,
                  variant: NutriLabelVariant.body,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}