import 'package:flutter/material.dart';
import 'home.dart';
import 'meals.dart';
import 'products.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final Color primaryGreen = const Color(0xFF344E41);
  final Color lightSage = const Color(0xFFA3B18A);
  final Color offWhite = const Color(0xFFDAD7CD);
  final Color darkOverlay = const Color(0xFF0D1A10);
  final Color darkInput = const Color(0xFF2C4035);
  final Color borderGreen = const Color(0xFF4A6B54);
  final Color textMuted = const Color(0xFF6B8C74);

  int _currentIndex = 3;

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Products()),
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderGreen),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Icon(Icons.arrow_back, color: lightSage, size: 18),
          ),
        ),
        title: Text(
          'Scan Barcode',
          style: TextStyle(color: offWhite, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Área da Câmara 
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: darkOverlay,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.videocam_off, color: borderGreen, size: 40),
                  _buildScannerOverlay(lightSage),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Aponta a câmara para o código de barras do produto',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 14, height: 1.4),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderGreen),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Inserir código manualmente',
                style: TextStyle(color: lightSage, fontSize: 14),
              ),
            ),
          ),
          
          const Spacer(), 
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Refeições'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(Color color) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          _buildCorner(color, top: 0, left: 0, isTop: true, isLeft: true),
          _buildCorner(color, top: 0, right: 0, isTop: true, isLeft: false),
          _buildCorner(color, bottom: 0, left: 0, isTop: false, isLeft: true),
          _buildCorner(color, bottom: 0, right: 0, isTop: false, isLeft: false),
          Center(
            child: Container(
              width: 180,
              height: 2,
              color: color.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Color color, {double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}