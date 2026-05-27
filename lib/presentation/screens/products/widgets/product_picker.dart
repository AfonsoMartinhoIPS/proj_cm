import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';
import 'package:nutri_scan/presentation/screens/products/product_details_screen.dart'
    show productByBarcodeProvider;
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Reusable widget that lets the user pick a [Product] from the saved-products list.
///
/// Renders a search field, a "scan" shortcut button, and a list of matching
/// saved products. When the user taps a row, the saved snapshot is upgraded to
/// the full [Product] (with nutriments) via [productByBarcodeProvider] and
/// handed to [onPick].
///
/// Used by `AddMealScreen` and intended for any future screen that needs a
/// product picker (e.g. shopping price entry).
class ProductPicker extends ConsumerStatefulWidget {
  /// Fired once the user has chosen a product and the full document has been
  /// fetched from `products/{barcode}`.
  final ValueChanged<Product> onPick;

  const ProductPicker({super.key, required this.onPick});

  @override
  ConsumerState<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<ProductPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Saved products are stored as snapshots (name, brand, kcal/100g) to keep
  /// the saved-list query light. To actually use a product (e.g. add it to a
  /// meal) we need the full Nutriments, so fetch the full Product by barcode.
  Future<void> _select(String barcode) async {
    final product = await ref.read(productByBarcodeProvider(barcode).future);
    if (product != null && mounted) widget.onPick(product);
  }

  /// Opens the scanner in "pick" mode. It pops back with the scanned barcode,
  /// then we resolve the full product the same way as picking from the saved
  /// list. Lives on its own route (`/scanner/pick`) so pushing from screens
  /// outside the bottom-nav ShellRoute doesn't remount MainShell.
  Future<void> _openScanner() async {
    final barcode = await context.push<String>('/scanner/pick');
    if (barcode != null && barcode.isNotEmpty) {
      await _select(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedProductsProvider).value ?? [];
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? saved
        : saved
            .where((s) =>
                s.name.toLowerCase().contains(query) ||
                (s.brand ?? '').toLowerCase().contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutriLabel(
          'PRODUTO',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
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
          icon: const Icon(
            Icons.qr_code_scanner,
            size: 18,
            color: AppColors.secondary,
          ),
          onPressed: _openScanner,
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const NutriLabel(
            'Nenhum produto guardado.',
            variant: NutriLabelVariant.small,
            color: AppColors.textMuted,
          )
        else
          // TODO: Create a separate ProductListItem widget that also shows kcal/100g and brand.
          ...filtered.map(
            (saved) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: NutriLabel(saved.name, variant: NutriLabelVariant.body),
              subtitle: (saved.brand ?? '').isEmpty
                  ? null
                  : NutriLabel(
                      saved.brand!,
                      variant: NutriLabelVariant.small,
                      color: AppColors.textMuted,
                    ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: () => _select(saved.barcode),
            ),
          ),
      ],
    );
  }
}
