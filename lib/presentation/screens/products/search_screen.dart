import 'package:flutter/material.dart';

import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repo = ProductRepositoryImpl();
  final _controller = TextEditingController();

  bool _isLoading = false;
  Product? _result;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final product = await _repo.getByBarcode(query);
      setState(() {
        _result = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Barcode',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _search,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Search'),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_result == null && !_isLoading && _error == null && _controller.text.isNotEmpty)
            const Text('Product not found'),
          if (_result != null) _buildResult(_result!),
        ],
      ),
    );
  }

  Widget _buildResult(Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            if (product.brand != null) Text(product.brand!),
            const SizedBox(height: 8),
            Text('Calories: ${product.nutriments.caloriesPer100g ?? '—'} kcal/100g'),
            Text('Protein:  ${product.nutriments.proteinPer100g ?? '—'} g/100g'),
            Text('Carbs:    ${product.nutriments.carbsPer100g ?? '—'} g/100g'),
            Text('Fat:      ${product.nutriments.fatPer100g ?? '—'} g/100g'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
