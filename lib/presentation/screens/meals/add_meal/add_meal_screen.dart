import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal/add_meal_general.dart';
import 'package:nutri_scan/presentation/screens/meals/add_meal/add_meal_product_selected.dart';
import 'package:nutri_scan/presentation/screens/products/widgets/product_picker.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';


/// TODO: This should be done at the provider level
/// Builds the YYYY-MM-DD doc id used by `nutrition_logs/{date}` in Firestore.
String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Screen for adding a [MealEntry] to a given day's nutrition log.
///
/// Composed of three sections:
///   1. [AddMealGeneralInfo] — meal type + date (always visible).
///   2. [ProductPicker] — shown when no product is selected.
///   3. [AddMealProductSelected] — shown once a product is picked; renders the
///      product card, serving input and nutrition table.
///
/// The "Save" button is enabled only when a product is selected
/// and the servings field parses to a positive number.
///
/// Can be opened with a pre-selected [Product] (e.g. from product details
/// pushing `'/meals/add'` with `extra: product`).
class AddMealScreen extends ConsumerStatefulWidget {
  /// Product to pre-fill the form with (skips the picker step).
  final Product? initialProduct;

  const AddMealScreen({super.key, this.initialProduct});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  // Shared form state — local to the screen, no provider needed.
  Product? _selectedProduct;
  MealType _mealType = MealType.lunch;
  DateTime _date = DateTime.now();
  final _servingsController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
    // Rebuild on every keystroke so `_canSubmit` re-evaluates and the
    // save button enables/disables in real time.
    _servingsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  /// Submit is allowed only when a product is picked and servings is positive.
  bool get _canSubmit {
    if (_selectedProduct == null) return false;
    final grams = double.tryParse(_servingsController.text.trim());
    return grams != null && grams > 0;
  }

  /// Builds the [MealEntry] from the current form state, hands it to
  /// [nutritionLogsProvider] for persistence + cache splice. Pops on success.
  Future<void> _submit() async {
    final product = _selectedProduct;
    if (product == null) return;
    final grams = double.tryParse(_servingsController.text.trim()) ?? 0;
    if (grams <= 0) return;

    // Scale per-100g nutriments to the actual consumed serving, then store
    // the resulting totals on the entry. We do the math here once so the
    // Firestore doc holds final values that any reader can display as-is.
    final n = product.nutriments;
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

    await ref
        .read(nutritionLogsProvider.notifier)
        .addEntry(entry, date: _dateKey(_date));

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NutriTopNavBar(
        showBackButton: true,
        title: 'Adicionar refeição',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Always visible: meal type + date.
            AddMealGeneralInfo(
              mealType: _mealType,
              date: _date,
              onMealTypeChanged: (t) => setState(() => _mealType = t),
              onDateChanged: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 24),

            // Product picker vs selected based on `_selectedProduct`.
            if (_selectedProduct == null)
              ProductPicker(
                onPick: (product) =>
                    setState(() => _selectedProduct = product),
              )
            else
              AddMealProductSelected(
                product: _selectedProduct!,
                servingsController: _servingsController,
                onChange: () => setState(() => _selectedProduct = null),
              ),

            const SizedBox(height: 32),
            NutriButton(
              label: 'Guardar refeição',
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
