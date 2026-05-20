import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';
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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Produtos',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => context.push('/scan'),
                  icon: const Icon(Icons.add, color: AppColors.secondary, size: 18),
                  label: const Text('Novo', style: TextStyle(color: AppColors.secondary)),
                ),
              ],
            ),
          ),
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
                child: Text('Erro: $e', style: const TextStyle(color: AppColors.textMuted)),
              ),
              data: (savedProducts) {
                final filtered = _filter(savedProducts);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Ainda não guardaste nenhum produto.'
                          : 'Nenhum produto encontrado.',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                      onTap: () => context.push('/products/${savedProduct.barcode}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
          border: Border(bottom: BorderSide(color: AppColors.surfaceDark.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            _thumbnail(),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(savedProduct.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.onBackground, fontSize: 14, fontWeight: FontWeight.w600)),
                  if ((savedProduct.brand ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(savedProduct.brand!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ],
              ),
            ),
            Text(
              savedProduct.caloriesPer100g != null
                  ? '${savedProduct.caloriesPer100g!.toStringAsFixed(0)} kcal'
                  : '— kcal',
              style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final url = savedProduct.imageUrl;
    final fallbackLetter = savedProduct.name.isNotEmpty ? savedProduct.name[0].toUpperCase() : '?';

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
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
              errorBuilder: (_, _, _) =>
                  Text(fallbackLetter, style: const TextStyle(color: AppColors.onBackground, fontSize: 18)),
            )
          : Text(fallbackLetter, style: const TextStyle(color: AppColors.onBackground, fontSize: 18)),
    );
  }
}
