import 'package:flutter/material.dart';

import 'home.dart';
import 'meals.dart';
import 'products.dart';
import 'scan.dart';

class Creditos extends StatefulWidget {
  const Creditos({super.key});

  @override
  State<Creditos> createState() => _CreditosState();
}

class _CreditosState extends State<Creditos> {
  final Color primaryGreen = const Color(0xFF344E41);
  final Color secondaryGreen = const Color(0xFF3A5A40);
  final Color accentGreen = const Color(0xFFA3B18A);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textLight = const Color(0xFFDAD7CD);
  final Color textDim = const Color(0xFF6B8C74);
  final Color darkBg = const Color(0xFF2C4035);
  final Color buttonGreen = const Color(0xFF588157);

  int _currentIndex = 1; // Mantendo o índice do Perfil/Menu

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Lógica de navegação igual ao perfil.dart
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Meals()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Products()),
      );
    }
    if (index == 3) {
      Navigator.pushReplacement(
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Créditos',
          style: TextStyle(
            color: textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          // Logótipo e Versão
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: buttonGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: textLight,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 15),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nutri',
                        style: TextStyle(
                          color: textLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Scan',
                        style: TextStyle(
                          color: accentGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'versão 1.0.0 · 2025–2026',
                  style: TextStyle(color: textDim, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Text(
            'Unidade Curricular, Computação Móvel',
            style: TextStyle(color: textDim, fontSize: 12),
          ),
          Text(
            'Instituição, Instituto Politécnico de Setúbal',
            style: TextStyle(color: textDim, fontSize: 12),
          ),

          const SizedBox(height: 30),

          Text(
            'EQUIPA',
            style: TextStyle(
              color: textDim,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),

          // Lista da Equipa
          _buildMemberTile('Afonso Martinho', '202001865', 'AM'),
          _buildMemberTile('Daniel Pais', '202200286', 'DP'),
          _buildMemberTile('Fernando Ramalho', '202002203', 'FR'),
          _buildMemberTile('Samuel Silva', '202200315', 'SS'),

          const SizedBox(height: 40),
          Text(
            'Feito com dedicação · IPS 2025/2026',
            textAlign: TextAlign.center,
            style: TextStyle(color: textDim, fontSize: 10),
          ),
          const SizedBox(height: 20),
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Refeições',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textDim, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(String name, String id, String initials) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGreen.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: secondaryGreen,
          child: Text(
            initials,
            style: TextStyle(
              color: accentGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: TextStyle(color: textLight, fontSize: 14)),
        subtitle: Text(id, style: TextStyle(color: textDim, fontSize: 11)),
      ),
    );
  }
}
