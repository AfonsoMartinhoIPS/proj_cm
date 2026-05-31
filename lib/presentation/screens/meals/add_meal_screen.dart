import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/product.dart';

/// Ecrã para adicionar uma nova refeição manualmente.
///
/// Permite ao utilizador introduzir o nome do produto, a quantidade em gramas
/// e o tipo de refeição. Pode receber um [initialProduct] para pré‑preencher
/// o nome e a quantidade padrão de 100 g.
class AddMealScreen extends StatelessWidget {
  /// Produto opcional para pré‑preencher o formulário.
  final Product? initialProduct;

  /// Cria um [AddMealScreen].
  ///
  /// Se [initialProduct] for fornecido, o campo de nome será preenchido
  /// automaticamente com o nome do produto.
  const AddMealScreen({super.key, this.initialProduct});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(showBackButton: true, title: 'Adicionar Refeição'),
      body: SafeArea(
        child: AddMealForm(initialProduct: initialProduct),
      ),
    );
  }
}

/// Formulário para adicionar uma refeição.
///
/// Contém os campos de nome do produto, quantidade em gramas e o tipo de
/// refeição (pequeno‑almoço, almoço, jantar ou snack).
class AddMealForm extends ConsumerStatefulWidget {
  /// Produto opcional para pré‑preencher o nome e a quantidade.
  final Product? initialProduct;

  /// Cria um [AddMealForm].
  const AddMealForm({super.key, this.initialProduct});

  @override
  ConsumerState<AddMealForm> createState() => _AddMealFormState();
}

/// Estado do [AddMealForm] que gere os campos de texto e a submissão.
class _AddMealFormState extends ConsumerState<AddMealForm> {
  Product? selectedProduct;
  MealType selectedMealType = MealType.lunch;

  TextEditingController nameController = TextEditingController();
  TextEditingController servingGrams = TextEditingController(text: '0.0');

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      selectedProduct = widget.initialProduct;
    }

    nameController.text = selectedProduct?.name ?? '';
    servingGrams.text = '100';
  }

  /// Submete os dados da refeição.
  ///
  /// A implementação da lógica de submissão será adicionada posteriormente.
  void submit() {
    // Implementação futura
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          NutriTextField(
            controller: nameController,
            label: 'Nome do produto',
            hint: 'Ex. Iogurte natural',
          ),
          const SizedBox(height: 12),
          NutriTextField(
            controller: servingGrams,
            label: 'Quantidade (g)',
            hint: '100',
            keyboardType: TextInputType.number,
          ),
          DropdownButton<MealType>(
            value: selectedMealType,
            items: MealType.values
                .map(
                  (meal) => DropdownMenuItem(
                    value: meal,
                    child: NutriLabel(meal.toString().split('.').last),
                  ),
                )
                .toList(),
            onChanged: (meal) {
              if (meal != null) setState(() => selectedMealType = meal);
            },
          ),
          NutriButton(
            label: 'Salvar Refeição',
            onPressed: submit,
          ),
        ],
      ),
    );
  }
}