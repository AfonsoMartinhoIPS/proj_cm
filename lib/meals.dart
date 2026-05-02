import 'package:flutter/material.dart';
import 'products.dart';
import 'scan.dart';
import 'home.dart';

class Meals extends StatefulWidget {
  const Meals({super.key});

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  
  final Color primaryGreen = const Color(0xFF344E41);
  final Color secondaryGreen = const Color(0xFF3A5A40);
  final Color accentGreen = const Color(0xFFA3B18A);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textLight = const Color(0xFFDAD7CD);
  final Color textDim = const Color(0xFF6B8C74);
  final Color darkBg = const Color(0xFF2C4035);

  int _currentIndex = 1;

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
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Products()),
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
      body: SafeArea(
        child: _buildMealsContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkBg,
        selectedItemColor: accentGreen,
        unselectedItemColor: textDim,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Refeições'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        ],
      ),
    );
  }

  // Conteúdo principal da página de refeições
  Widget _buildMealsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Refeições', 
                style: TextStyle(color: textLight, fontSize: 22, fontWeight: FontWeight.bold)
              ),
              Text('21 Abr', 
                style: TextStyle(color: accentGreen, fontSize: 14)
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Hoje · 1 124 kcal consumidas', 
            style: TextStyle(color: textDim, fontSize: 14)
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMealCard(
                title: 'Pequeno-almoço',
                totalKcal: '342 kcal',
                items: [
                  {'name': 'Iogurte grego', 'kcal': '120 kcal'},
                  {'name': 'Granola', 'kcal': '180 kcal'},
                ],
              ),
              _buildMealCard(
                title: 'Almoço',
                totalKcal: '480 kcal',
                items: [
                  {'name': 'Peito de frango', 'kcal': '220 kcal'},
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderGreen),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('+ Adicionar refeição', 
                  style: TextStyle(color: accentGreen)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({required String title, required String totalKcal, required List<Map<String, String>> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), 
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: darkBg.withOpacity(0.5)))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
                Text(totalKcal, style: TextStyle(color: accentGreen, fontSize: 12)),
              ],
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['name']!, style: TextStyle(color: textLight.withOpacity(0.9), fontSize: 13)),
                Text(item['kcal']!, style: TextStyle(color: textDim, fontSize: 13)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}