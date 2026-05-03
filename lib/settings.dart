import 'package:flutter/material.dart';

import 'home.dart';
import 'meals.dart';
import 'products.dart';
import 'scan.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  final Color primaryGreen = const Color(0xFF344E41);
  final Color secondaryGreen = const Color(0xFF3A5A40);
  final Color accentGreen = const Color(0xFFA3B18A);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textLight = const Color(0xFFDAD7CD);
  final Color textDim = const Color(0xFF6B8C74);
  final Color darkBg = const Color(0xFF2C4035);
  final Color buttonGreen = const Color(0xFF588157);

  int _currentIndex = 0;

  void _onTabTapped(int index) {
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Products()),
      );
    } else if (index == 3) {
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
          'Definições',
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
          _buildSectionTitle('NOTIFICAÇÕES'),
          _buildSettingTile(
            'Lembrete de refeição',
            'Alerta antes das horas das refeições',
            true,
          ),
          _buildSettingTile('Resumo diário', 'Resumo às 22h00', true),
          _buildSettingTile(
            'Objetivo atingido',
            'Notificar quando atinges a meta',
            false,
          ),

          const SizedBox(height: 25),

          _buildSectionTitle('PREFERÊNCIAS'),
          _buildSettingTile('Unidades métricas', 'kg e cm', true),
          _buildSettingTile('Modo escuro', 'Tema da aplicação', true),
        ],
      ),
      // BARRA DE NAVEGAÇÃO
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: TextStyle(
          color: textDim,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGreen.withOpacity(0.5)),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textLight, fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: textDim, fontSize: 11),
        ),
        trailing: Switch(
          value: value,
          activeColor: accentGreen,
          activeTrackColor: buttonGreen,
          onChanged: (bool newValue) {},
        ),
      ),
    );
  }
}
