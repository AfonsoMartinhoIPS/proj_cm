// lib/presentation/screens/products/products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Local substring match against name + brand. Case-insensitive.
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
    final asyncSaved = ref.watch(savedProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NutriTopNavBar(
        showBackButton: false,
        title: 'Produtos',
        actions: [
          NutriButton.text(
            label: 'Novo',
            onPressed: () => context.push('/scan'),
            icon: const Icon(Icons.add, color: AppColors.secondary, size: 18),
          ),
        ],
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
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width:
                              180,
                          child: NutriButton.transparent(
                            label: 'Tentar novamente',
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.secondary,
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
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NutriLabel(
                              _query.isEmpty
                                  ? 'Ainda não guardaste nenhum produto.'
                                  : 'Nenhum produto encontrado para "$_query".',
                              textAlign: TextAlign.center,
                              color: AppColors.textMuted,
                              variant: NutriLabelVariant.body,
                            ),
                            const SizedBox(height: 16),
                            if (_query.isEmpty) ...[
                              SizedBox(
                                width: 200,
                                child: NutriButton(
                                  label: 'Faz o teu 1º scan',
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: AppColors.onBackground,
                                    size: 18,
                                  ),
                                  onPressed: () => context.push('/scan'),
                                ),
                              ),
                            ] else ...[
                              NutriButton.text(
                                label: 'Limpar pesquisa',
                                fontSize: 14,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
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

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.savedProduct, required this.onTap});

  final SavedProduct savedProduct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            _thumbnail(),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    savedProduct.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.onBackground,
                    variant: NutriLabelVariant.body,
                    fontWeight: FontWeight.w600,
                  ),
                  if ((savedProduct.brand ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    NutriLabel(
                      savedProduct.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textMuted,
                      variant: NutriLabelVariant.body,
                    ),
                  ],
                ],
              ),
            ),
            NutriLabel(
              savedProduct.caloriesPer100g != null
                  ? '${savedProduct.caloriesPer100g!.toStringAsFixed(0)} kcal'
                  : '— kcal',
              color: AppColors.secondary,
              variant: NutriLabelVariant.body,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final url = savedProduct.imageUrl;
    final fallbackLetter = savedProduct.name.isNotEmpty
        ? savedProduct.name[0].toUpperCase()
        : '?';

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => NutriLabel(
                fallbackLetter,
                color: AppColors.onBackground,
                variant: NutriLabelVariant.bodyLarge,
              ),
            )
          : NutriLabel(
              fallbackLetter,
              color: AppColors.onBackground,
              variant: NutriLabelVariant.bodyLarge,
            ),
    );
  }
}
