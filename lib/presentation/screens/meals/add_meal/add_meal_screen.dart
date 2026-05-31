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
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã para adicionar ou editar uma entrada de refeição.
///
/// Funciona em dois modos:
/// - **Adição** (padrão): tipo de refeição, data, seletor de produto e
///   formulário de porção. Cria uma nova entrada e chama
///   `nutritionLogsProvider.addEntry`.
/// - **Edição**: requer [editingEntry] e [editingDate]. O produto é fixo
///   (recarregado via [ProductRepositoryImpl] para obter os [Nutriments]).
///   O utilizador só pode alterar o tipo de refeição e as gramas da porção.
///   A data também é fixa — mover uma entrada entre dias exigiria uma
///   transação de remoção + adição, fora do âmbito atual.
///   A gravação chama `nutritionLogsProvider.moveEntry`.
///
/// Também pode ser aberta em modo de adição com um produto pré‑selecionado
/// através de [initialProduct] (ex.: a partir do ecrã de detalhes do produto,
/// navegando para `/meals/add` com `extra: product`).
class AddMealScreen extends ConsumerStatefulWidget {
  /// Produto opcional já selecionado (modo de adição).
  final Product? initialProduct;

  /// Entrada que está a ser editada. Quando definida, o ecrã funciona em
  /// modo de edição.
  final MealEntry? editingEntry;

  /// Data (YYYY‑MM‑DD) do documento onde a entrada editada reside.
  ///
  /// Obrigatória quando [editingEntry] é fornecida, para que o provider
  /// saiba que dia deve alterar.
  final String? editingDate;

  /// Cria um [AddMealScreen].
  ///
  /// Se [editingEntry] for fornecida, [editingDate] também deve ser.
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

/// Estado do [AddMealScreen] que gere o produto selecionado, o tipo de
/// refeição, a data e o controlador da porção.
class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  Product? _selectedProduct;
  MealType _mealType = MealType.lunch;
  DateTime _date = DateTime.now();
  final _servingsController = TextEditingController(text: '100');

  /// Indica se o ecrã está em modo de edição.
  bool get _isEditing => widget.editingEntry != null;
  bool _loadingProduct = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final entry = widget.editingEntry!;
      _mealType = entry.mealType;
      // Usa o dia registado no documento (analisado a partir de
      // `editingDate`) para que a data exibida corresponda ao balde
      // do documento, e não ao timestamp `loggedAt`, que pode estar
      // desfasado em edições perto da meia‑noite.
      _date = DateTime.tryParse(widget.editingDate!) ?? entry.loggedAt;
      _servingsController.text = entry.servingGrams.toStringAsFixed(0);
      _fetchEditingProduct(entry.productBarcode);
    } else {
      _selectedProduct = widget.initialProduct;
    }
    _servingsController.addListener(() => setState(() {}));
  }

  /// Carrega o [Product] completo a partir do código de barras da entrada
  /// que está a ser editada.
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

  /// Indica se os campos obrigatórios estão preenchidos e o formulário
  /// pode ser submetido.
  bool get _canSubmit {
    if (_selectedProduct == null) return false;
    final grams = double.tryParse(_servingsController.text.trim());
    return grams != null && grams > 0;
  }

  /// Submete a entrada (adição ou edição).
  ///
  /// Constrói um [MealEntry] com os dados atuais do formulário e chama
  /// o notifier adequado ([addEntry] ou [moveEntry]). Após a operação,
  /// fecha o ecrã atual.
  Future<void> _submit() async {
    final product = _selectedProduct;
    if (product == null) return;
    final grams = double.tryParse(_servingsController.text.trim()) ?? 0;
    if (grams <= 0) return;

    final n = product.nutriments;
    final notifier = ref.read(nutritionLogsProvider.notifier);

    if (_isEditing) {
      final original = widget.editingEntry!;
      final newDate = dateKey(_date);
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
      await notifier.moveEntry(
        updated,
        oldDate: widget.editingDate!,
        newDate: newDate,
      );
      if (!mounted) return;
      NutriFeedback.showSuccess(context, 'Refeição atualizada');
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
      if (!mounted) return;
      NutriFeedback.showSuccess(context, 'Refeição adicionada');
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
              onDateChanged: (d) => setState(() => _date = d),
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
                showChange: !_isEditing,
                onChange: () => setState(() => _selectedProduct = null),
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