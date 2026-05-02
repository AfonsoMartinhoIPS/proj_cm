import 'package:flutter/material.dart';


// import 'settings.dart';
import 'meals.dart';
import 'products.dart';
import 'scan.dart';
import 'home.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
 
  final Color primaryGreen = const Color(0xFF344E41);
  final Color secondaryGreen = const Color(0xFF3A5A40);
  final Color accentGreen = const Color(0xFFA3B18A);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textLight = const Color(0xFFDAD7CD);
  final Color textDim = const Color(0xFF6B8C74);
  final Color darkBg = const Color(0xFF2C4035);
  final Color buttonGreen = const Color(0xFF588157);

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
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Products()),
      );
      
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Meals()),
      );
    }else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Scanner()),
      );
    }
  }

  void _goToSettings() {
 
    print("Navegar para Settings"); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil',
                  style: TextStyle(
                    color: textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Cartão de Informação do Utilizador
                  _buildUserHeader(),
                  
                  const SizedBox(height: 20),

                  // Secção de Objetivos Diários
                  _buildGoalsSection(),

                  const SizedBox(height: 30),

                  // Botão Definições
                  _buildMenuButton(
                    label: 'Definições',
                    onPressed: _goToSettings,
                  ),

                  const SizedBox(height: 15),

                  // Botão Créditos
                  _buildMenuButton(
                    label: 'Créditos',
                    onPressed: () {
                      print("Créditos clicados");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkBg,
        selectedItemColor: accentGreen,
        unselectedItemColor: textDim,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Refeições'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGreen),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: buttonGreen,
            child: Icon(Icons.person, color: textLight, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ana Ferreira',
                  style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ana@email.com',
                  style: TextStyle(color: textDim, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag('Perder Peso'),
                    const SizedBox(width: 8),
                    _buildTag('Editar Perfil', isAction: true),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, {bool isAction = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAction ? Colors.transparent : buttonGreen,
        border: isAction ? Border.all(color: borderGreen) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: textLight, fontSize: 10),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OBJETIVOS DIÁRIOS',
            style: TextStyle(color: textDim, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalItem('1 580', 'kcal'),
              _buildGoalItem('125g', 'proteína'),
              _buildGoalItem('62kg', 'peso atual'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGoalItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: accentGreen, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: textDim, fontSize: 11)),
      ],
    );
  }

  Widget _buildMenuButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonGreen,
          foregroundColor: textLight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
