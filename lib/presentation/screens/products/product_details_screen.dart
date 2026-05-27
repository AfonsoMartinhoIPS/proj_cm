import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/product/product_nutriments.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';

/// Fetches the full Product from `products/{barcode}` (or API fallback via repo).
/// `.family` lets each barcode have its own cached entry.
final productByBarcodeProvider = FutureProvider.family<Product?, String>(
  (ref, barcode) => ProductRepositoryImpl().getByBarcode(barcode),
);

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productByBarcodeProvider(barcode));

    // Watch the saved list and pick the one matching this barcode (null if not saved yet).
    // When user taps "Guardar" → provider list changes → rebuild → savedProduct goes from null → SavedProduct.
    final SavedProduct? savedProduct = ref
        .watch(savedProductsProvider)
        .value
        ?.cast<SavedProduct?>()
        .firstWhere((s) => s!.barcode == barcode, orElse: () => null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NutriTopNavBar(showBackButton: true, title: 'Detalhes do Produto'),
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: NutriLabel( 
            'Erro: $e',
            color: AppColors.textMuted
          ),
        ),
        data: (product) {
          if (product == null) {
            return const Center(
              child: NutriLabel( 
                'Produto não encontrado.',
                color: AppColors.textMuted), 
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductHeader(product: product),
                const SizedBox(height: 24),
                ProductNutritionTable(product: product),
                const SizedBox(height: 24),
                _ActionButtons(product: product, isSaved: savedProduct != null),
                if (savedProduct != null) ...[
                  const SizedBox(height: 24),
                  _NotesSection(savedProduct: savedProduct),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.product, required this.isSaved});

  final Product product;
  final bool isSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: NutriButton.transparent(
            label: isSaved ? 'Remover' : 'Guardar',
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: AppColors.secondary,
              size: 18,
            ),
            onPressed: () {
              final notifier = ref.read(savedProductsProvider.notifier);
              if (isSaved) {
                notifier.removeProduct(product.barcode);
                NutriFeedback.showInfo(context, 'Produto removido');
              } else {
                notifier.saveProduct(product);
                NutriFeedback.showSuccess(context, 'Produto guardado');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NutriButton(
            label: 'Add refeição',
            icon: const Icon(
              Icons.restaurant,
              color: AppColors.onBackground,
              size: 18,
            ),
            onPressed: () => context.push('/meals/add', extra: product),
          ),
        ),
      ],
    );
  }
}

class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.savedProduct});

  final SavedProduct savedProduct;

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddNoteSheet(
        onSubmit: (text) {
          final updated = [
            ...savedProduct.notes,
            SavedProductNote(text: text, createdAt: DateTime.now()), 
          ];
          ref
              .read(savedProductsProvider.notifier)
              .setNotes(savedProduct.barcode, updated);
        },
      ),
    );
  }

  void _removeNote(WidgetRef ref, int index) {
    final updated = [...savedProduct.notes]..removeAt(index);
    ref
        .read(savedProductsProvider.notifier)
        .setNotes(savedProduct.barcode, updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const NutriLabel(
                'NOTAS',
                color: AppColors.textMuted,
                variant: NutriLabelVariant.small,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
              NutriLabel(
                'Guardado em ${_fmt(savedProduct.savedAt)}',
                color: AppColors.textMuted,
                variant: NutriLabelVariant.small,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (savedProduct.notes.isEmpty)
            const NutriLabel(
              'Ainda não adicionaste notas a este produto.',
              color: AppColors.textMuted, variant: NutriLabelVariant.body,
            )
          else
            ...List.generate(savedProduct.notes.length, (i) {
              final note = savedProduct.notes[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NutriLabel( 
                            note.text,
                              color: AppColors.onBackground,
                              variant: NutriLabelVariant.body,
                          ),
                          const SizedBox(height: 2),
                            NutriLabel( 
                            _fmt(note.createdAt),
                              color: AppColors.textMuted,
                              variant: NutriLabelVariant.small,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      onPressed: () => _removeNote(ref, i),
                      tooltip: 'Remover nota',
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          NutriButton.text( 
            label: 'Adicionar nota',
            fontSize: 13,
            icon: const Icon(Icons.add, color: AppColors.secondary, size: 16),
            onPressed: () => _openAddSheet(context, ref),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Bottom sheet for composing a new note. Owns its TextEditingController.
class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet({required this.onSubmit});

  final void Function(String text) onSubmit;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      NutriFeedback.showError(context, 'Escreve algo na nota');
      return;
    }
    Navigator.of(context).pop();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NutriLabel( 
            'Nova nota',
              color: AppColors.onBackground,
              variant: NutriLabelVariant.bodyLarge,
              fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          NutriTextField(
            controller: _controller,
            label: 'Nota',
            hint: 'Ex. Continente 2.49€, bom para pós-treino',
            icon: Icons.note_alt_outlined,
            autofocus: true,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          NutriButton(label: 'Guardar Nota', onPressed: _submit),
        ],
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl ?? product.imageThumbnailUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            // TODO: replace with NutriCard widget
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: (url != null && url.isNotEmpty)
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported,
                    color: AppColors.textMuted,
                  ),
                )
              : const Icon(
                  Icons.fastfood,
                  color: AppColors.textMuted,
                  size: 32,
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NutriLabel( 
                product.name,
                  color: AppColors.onBackground,
                  variant: NutriLabelVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
              ),
              if ((product.brand ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                NutriLabel(
                  product.brand!,
                    color: AppColors.textMuted,
                  variant: NutriLabelVariant.body,
                ),
              ],
              if ((product.displayQuantity ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                NutriLabel( 
                  product.displayQuantity!,
                  variant: NutriLabelVariant.small,
                    color: AppColors.textMuted,
                ),
              ],
              const SizedBox(height: 6),
              NutriLabel( 
                'Cód: ${product.barcode}',
                  color: AppColors.textMuted,
                variant: NutriLabelVariant.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionTable extends StatelessWidget {
  const _NutritionTable({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final n = product.nutriments;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // TODO: replace with NutriCard widget
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NutriLabel(
            'POR 100G / 100ML',
            color: AppColors.textMuted,
            variant: NutriLabelVariant.small,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          _row('Calorias', n.caloriesPer100g, 'kcal'),
          _row('Proteína', n.proteinPer100g, 'g'),
          _row('Hidratos', n.carbsPer100g, 'g'),
          _row('  dos quais açúcares', n.sugarsPer100g, 'g'),
          _row('Gordura', n.fatPer100g, 'g'),
          _row('  das quais saturadas', n.saturatedFatPer100g, 'g'),
          _row('Fibra', n.fiberPer100g, 'g'),
          _row('Sal', n.saltPer100g, 'g'),
        ],
      ),
    );
  }

  Widget _row(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NutriLabel( 
            label,
            color: AppColors.textMuted, variant: NutriLabelVariant.small),
          NutriLabel( 
            value != null ? '${value.toStringAsFixed(1)} $unit' : '- $unit',
              variant: NutriLabelVariant.small,
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
