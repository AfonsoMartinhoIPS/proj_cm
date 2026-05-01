import 'package:flutter/material.dart';

class Produtos extends StatelessWidget {
  const Produtos({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF344E41);
    const accentGreen = Color(0xFF588157);
    const lightSage = Color(0xFFA3B18A);
    const offWhite = Color(0xFFDAD7CD);
    const cardGreen = Color(0xFF3A5A40);
    const darkInput = Color(0xFF2C4035);
    const borderGreen = Color(0xFF4A6B54);
    const textMuted = Color(0xFF6B8C74);

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Produtos',
          style: TextStyle(color: offWhite, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: lightSage, size: 18),
            label: const Text('Novo', style: TextStyle(color: lightSage)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              style: const TextStyle(color: offWhite),
              decoration: InputDecoration(
                hintText: 'Pesquisar produtos guardados',
                hintStyle: const TextStyle(color: textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: textMuted),
                filled: true,
                fillColor: darkInput,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderGreen),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderGreen),
                ),
              ),
            ),
          ),

          // Filtros (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Todos', isSelected: true, activeColor: accentGreen, textColor: offWhite),
                const SizedBox(width: 10),
                _buildFilterChip('Favoritos', isSelected: false, activeColor: darkInput, textColor: textMuted, borderColor: borderGreen),
                const SizedBox(width: 10),
                _buildFilterChip('Recentes', isSelected: false, activeColor: darkInput, textColor: textMuted, borderColor: borderGreen),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Lista de Produtos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildProductItem('Peito de frango', 'por 100g', '165 kcal', '🍗', offWhite, textMuted, lightSage, darkInput),
                _buildProductItem('Abacate', 'por 100g', '160 kcal', '🥑', offWhite, textMuted, lightSage, darkInput),
                _buildProductItem('Manteiga de amendoim', 'Calvé · por 30g', '188 kcal', '🥜', offWhite, textMuted, lightSage, darkInput),
                _buildProductItem('Arroz integral', 'por 100g cozido', '111 kcal', '🍚', offWhite, textMuted, lightSage, darkInput),
                _buildProductItem('Sumo de laranja', 'Compal · 200ml', '92 kcal', '🧃', offWhite, textMuted, lightSage, darkInput),
                // Podes adicionar quantos itens quiseres aqui, a lista fará scroll automaticamente
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: darkInput,
        currentIndex: 2, // Índice de Produtos
        type: BottomNavigationBarType.fixed,
        selectedItemColor: lightSage,
        unselectedItemColor: textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Refeições'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        ],
      ),
    );
  }

  // Widget para os filtros (Todos, Favoritos, etc)
  Widget _buildFilterChip(String label, {required bool isSelected, required Color activeColor, required Color textColor, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: activeColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Widget para cada linha da lista de produtos
  Widget _buildProductItem(String name, String subtitle, String calories, String emoji, Color titleCol, Color subCol, Color kcalCol, Color borderCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderCol.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // Ícone/Emoji
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF3A5A40),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4A6B54)),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 15),
          // Nome e Subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: titleCol, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: subCol, fontSize: 12),
                ),
              ],
            ),
          ),
          // Calorias
          Text(
            calories,
            style: TextStyle(color: kcalCol, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}