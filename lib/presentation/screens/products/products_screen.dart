import 'package:flutter/material.dart';
import 'package:projeto/core/theme/app_colors.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: AppColors.secondary, size: 18),
                  label: const Text('Novo', style: TextStyle(color: AppColors.secondary)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(
                hintText: 'Pesquisar produtos guardados',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _filterChip('Todos', isSelected: true),
                const SizedBox(width: 10),
                _filterChip('Favoritos'),
                const SizedBox(width: 10),
                _filterChip('Recentes'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildProductItem('Peito de frango', 'por 100g', '165 kcal', '🍗'),
                _buildProductItem('Abacate', 'por 100g', '160 kcal', '🥑'),
                _buildProductItem('Manteiga de amendoim', 'Calvé · por 30g', '188 kcal', '🥜'),
                _buildProductItem('Arroz integral', 'por 100g cozido', '111 kcal', '🍚'),
                _buildProductItem('Sumo de laranja', 'Compal · 200ml', '92 kcal', '🧃'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.onBackground : AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductItem(String name, String subtitle, String calories, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceDark.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: AppColors.onBackground, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(calories,
              style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
