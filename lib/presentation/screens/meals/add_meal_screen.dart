

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto/domain/entities/meal_entry.dart';
import 'package:projeto/domain/entities/product.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key, this.initialProduct});

  final Product? initialProduct;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:  Scaffold(
      appBar: AppBar(title: const Text('Adicionar Refeição')),
      body: AddMealForm(initialProduct: initialProduct),
    ));
  }
}


class AddMealForm extends ConsumerStatefulWidget {
  
  AddMealForm({super.key, this.initialProduct});
  final Product? initialProduct;

  @override
  ConsumerState<AddMealForm> createState() => _AddMealFormState();
}

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
    servingGrams.text = '100'; // default to 100g
        
  }

  void submit() {
    

    /*
    {
      id: string                // UUID
      mealType: "breakfast" | "lunch" | "dinner" | "snack"
      productId: string
      productBarcode: string
      productName: string       // snapshot — avoids extra read to products collection
      productImageUrl: string | null
      servingGrams: number      // actual amount consumed
      loggedAt: timestamp

      // pre-computed for this serving: (nutrientPer100g / 100) * servingGrams
      nutriments: {
        calories: number
        protein: number
        carbs: number
        fat: number
      }
    }
    */
  }


  @override
  Widget build(BuildContext context) {

    /*
      1. Fetch product from DB

    */


    

    return Center(
      child: Column(
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome do produto')),
          TextField(controller: servingGrams, decoration: const InputDecoration(labelText: 'Quantidade (g)'), keyboardType: TextInputType.number),
          DropdownButton<MealType>(
            value: selectedMealType,
            items: MealType.values.map((meal) => DropdownMenuItem(value: meal, child: Text(meal.toString().split('.').last))).toList(),
            onChanged: (meal) { if (meal != null) setState(() => selectedMealType = meal); },
          ),
          
          ElevatedButton(onPressed: submit, child: const Text('Salvar Refeição')),
        ],
      ),
    );
  }
}