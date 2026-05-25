import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal/add_meal_general.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal/add_meal_product_selected.dart';
import 'package:nutri_scan/presentation/screens/products/widgets/product_picker.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// Add/edit screen for a [MealEntry].
///
/// Two modes, switched via [editingEntry]:
///
///   * **Add** (default): meal type + date + product picker + serving form.
///     Hands a freshly-built entry to `nutritionLogsProvider.addEntry`.
///   * **Edit**: [editingEntry] + [editingDate] required. Product is locked
///     (refetched once via [ProductRepositoryImpl] for its per-100g
///     [Nutriments]); user can only change meal type and serving grams.
///     Date is locked too — moving an entry across days is out of scope and
///     would require a delete-on-old + add-on-new transaction.
///     Save calls `nutritionLogsProvider.updateEntry`.
///
/// Can also be opened in add-mode with a pre-selected [initialProduct]
/// (e.g. from product details pushing `/meals/add` with `extra: product`).
class AddMealScreen extends ConsumerStatefulWidget {
  final Product? initialProduct;

  /// Entry being edited. When set, the screen runs in edit mode.
  final MealEntry? editingEntry;

  /// YYYY-MM-DD doc id of the log the edited entry lives in. Required when
  /// [editingEntry] is set so the provider knows which day to mutate.
  final String? editingDate;

  const AddMealScreen({
    super.key,
    this.initialProduct,
    this.editingEntry,
    this.editingDate,
  }) : assert(
          editingEntry == null || editingDate != null,
          'editingDate is required when editingEntry is set',
        );

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  Product? _selectedProduct;
  MealType _mealType = MealType.lunch;
  DateTime _date = DateTime.now();
  final _servingsController = TextEditingController(text: '100');

  bool get _isEditing => widget.editingEntry != null;
  bool _loadingProduct = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final entry = widget.editingEntry!;
      _mealType = entry.mealType;
      _date = entry.loggedAt;
      _servingsController.text = entry.servingGrams.toStringAsFixed(0);
      _fetchEditingProduct(entry.productBarcode);
    } else {
      _selectedProduct = widget.initialProduct;
    }
    _servingsController.addListener(() => setState(() {}));
  }

  Future<void> _fetchEditingProduct(String barcode) async {
    setState(() => _loadingProduct = true);
    final product = await ProductRepositoryImpl().getByBarcode(barcode);
    if (!mounted) return;
    setState(() {
      _selectedProduct = product;
      _loadingProduct = false;
    });
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_selectedProduct == null) return false;
    final grams = double.tryParse(_servingsController.text.trim());
    return grams != null && grams > 0;
  }

  Future<void> _submit() async {
    final product = _selectedProduct;
    if (product == null) return;
    final grams = double.tryParse(_servingsController.text.trim()) ?? 0;
    if (grams <= 0) return;

    final n = product.nutriments;
    final notifier = ref.read(nutritionLogsProvider.notifier);

    if (_isEditing) {
      final original = widget.editingEntry!;
      final updated = MealEntry(
        id: original.id,
        productBarcode: original.productBarcode,
        productName: original.productName,
        productImageUrl: original.productImageUrl,
        mealType: _mealType,
        servingGrams: grams,
        calories: n.calories(grams: grams),
        protein: n.protein(grams: grams),
        carbs: n.carbs(grams: grams),
        fat: n.fat(grams: grams),
        loggedAt: original.loggedAt,
      );
      await notifier.updateEntry(updated, date: widget.editingDate);
    } else {
      final entry = MealEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productBarcode: product.barcode,
        productName: product.name,
        productImageUrl: product.imageThumbnailUrl ?? product.imageUrl,
        mealType: _mealType,
        servingGrams: grams,
        calories: n.calories(grams: grams),
        protein: n.protein(grams: grams),
        carbs: n.carbs(grams: grams),
        fat: n.fat(grams: grams),
        loggedAt: DateTime.now(),
      );
      await notifier.addEntry(entry, date: dateKey(_date));
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NutriTopNavBar(
        showBackButton: true,
        title: _isEditing ? 'Editar refeição' : 'Adicionar refeição',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AddMealGeneralInfo(
              mealType: _mealType,
              date: _date,
              onMealTypeChanged: (t) => setState(() => _mealType = t),
              onDateChanged: _isEditing ? (_) {} : (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 24),

            if (_loadingProduct)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_selectedProduct == null)
              ProductPicker(
                onPick: (product) =>
                    setState(() => _selectedProduct = product),
              )
            else
              AddMealProductSelected(
                product: _selectedProduct!,
                servingsController: _servingsController,
                // Lock product in edit mode — empty callback hides the "Mudar"
                // button effect (button still appears; this is a UX compromise
                // to avoid forking AddMealProductSelected for one flag).
                onChange: _isEditing
                    ? () {}
                    : () => setState(() => _selectedProduct = null),
              ),

            const SizedBox(height: 32),
            NutriButton(
              label: _isEditing ? 'Atualizar' : 'Guardar refeição',
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
