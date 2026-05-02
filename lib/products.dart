import 'package:flutter/material.dart';
import 'home.dart';
import 'meals.dart';
import 'scan.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final Color primaryGreen = const Color(0xFF344E41);
  final Color accentGreen = const Color(0xFF588157);
  final Color lightSage = const Color(0xFFA3B18A);
  final Color offWhite = const Color(0xFFDAD7CD);
  final Color darkInput = const Color(0xFF2C4035);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textMuted = const Color(0xFF6B8C74);

  int _currentIndex = 2;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Meals()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Scanner()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Produtos',
          style: TextStyle(color: Color(0xFFDAD7CD), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Color(0xFFA3B18A), size: 18),
            label: const Text('Novo', style: TextStyle(color: Color(0xFFA3B18A))),
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
              style: const TextStyle(color: Color(0xFFDAD7CD)),
              decoration: InputDecoration(
                hintText: 'Pesquisar produtos guardados',
                hintStyle: const TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B8C74)),
                filled: true,
                fillColor: darkInput,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderGreen),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderGreen),
                ),
              ),
            ),
          ),

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: darkInput,
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

  Widget _buildProductItem(String name, String subtitle, String calories, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: darkInput.withOpacity(0.5))),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: offWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(calories, style: TextStyle(color: lightSage, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}