import 'package:flutter/material.dart';

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF344E41);
    const lightSage = Color(0xFFA3B18A);
    const offWhite = Color(0xFFDAD7CD);
    const darkOverlay = Color(0xFF0D1A10);
    const darkInput = Color(0xFF2C4035);
    const borderGreen = Color(0xFF4A6B54);
    const textMuted = Color(0xFF6B8C74);

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
              side: const BorderSide(color: borderGreen),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.arrow_back, color: lightSage, size: 18),
          ),
        ),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: offWhite, fontSize: 16, fontWeight: FontWeight.w600),
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
                  //  Widget da Câmara
                  const Icon(Icons.videocam_off, color: borderGreen, size: 40),
                  
                  // Mira do Scanner
                  _buildScannerOverlay(lightSage),
                ],
              ),
            ),
          ),

          // Texto de Instrução
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Aponta a câmara para o código de barras do produto',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 14, height: 1.4),
            ),
          ),

          // Botão de Inserção Manual
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: borderGreen),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Inserir código manualmente',
                style: TextStyle(color: lightSage, fontSize: 14),
              ),
            ),
          ),
          
          const Spacer(), // Empurra o conteúdo para cima
        ],
      ),
      // Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: darkInput,
        currentIndex: 3, 
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