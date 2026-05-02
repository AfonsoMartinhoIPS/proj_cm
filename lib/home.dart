import 'package:flutter/material.dart';
import 'scan.dart';
import 'products.dart';
import 'meals.dart';
import 'perfil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  int _currentIndex = 0;

 
  void _onTabTapped(int index) {
  setState(() {
    _currentIndex = index;
  });

  if (index == 1) { 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Meals()), 
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
    const primaryGreen = Color(0xFF344E41);
    const accentGreen = Color(0xFF588157);
    const lightSage = Color(0xFFA3B18A);
    const offWhite = Color(0xFFDAD7CD);
    const cardGreen = Color(0xFF3A5A40);
    const darkInput = Color(0xFF2C4035);
    const textMuted = Color(0xFF6B8C74);

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: 
              // Cabeçalho: 
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bom dia, Ana',
          style: TextStyle(
            color: offWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Segunda-feira, 21 Abr',
          style: TextStyle(color: textMuted, fontSize: 13),
        ),
      ],
    ),
    // ALTERAÇÃO AQUI: Envolvemos o Container com GestureDetector
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PerfilPage()),
        );
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: cardGreen,
          shape: BoxShape.circle,
          border: Border.all(color: accentGreen, width: 2),
        ),
        child: const Icon(Icons.person, color: offWhite),
      ),
    ),
  ],
),

              const SizedBox(height: 24),

              // Card de Calorias principal
              _buildCalorieCard(cardGreen, accentGreen, lightSage, offWhite, textMuted, darkInput),

              const SizedBox(height: 24),

              // Secção "Esta semana" 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Esta semana',
                    style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver mais →', style: TextStyle(color: lightSage, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildWeeklyChart(cardGreen, accentGreen, lightSage, textMuted),

              const SizedBox(height: 24),

              // Refeições de hoje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Refeições de hoje',
                    style: TextStyle(color: offWhite, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todas', style: TextStyle(color: lightSage, fontSize: 12)),
                  ),
                ],
              ),
              _buildMealItem('Pequeno-almoço', '342 kcal', accentGreen, offWhite, lightSage, darkInput),
              _buildMealItem('Almoço', '480 kcal', accentGreen, offWhite, lightSage, darkInput),
              
              const SizedBox(height: 80), // Espaço para a Bottom Bar
            ],
          ),
        ),
      ),
      // Barra de Navegação Inferior
     bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex, // Define qual ícone fica "aceso"
  onTap: _onTabTapped,        // Chama a função de navegação ao clicar
  backgroundColor: const Color(0xFF2C4035), // darkInput
  type: BottomNavigationBarType.fixed,
  selectedItemColor: const Color(0xFFA3B18A), // lightSage
  unselectedItemColor: const Color(0xFF6B8C74), // textMuted
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Refeições'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produtos'),
    BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
  ],
),
    );
  }

  // Widget: Card de Calorias e Macros
  Widget _buildCalorieCard(Color bg, Color accent, Color light, Color white, Color muted, Color dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calorias hoje'.toUpperCase(), style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('1 124', style: TextStyle(color: light, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('de 1 580 kcal', style: TextStyle(color: muted, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                child: Text('71%', style: TextStyle(color: white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progresso principal
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.71,
              backgroundColor: dark,
              color: light,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          // Macros (Proteína, Hidratos, Gordura)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo('Proteína', '100/125g', 0.8, light, dark),
              _buildMacroInfo('Hidratos', '105/175g', 0.6, accent, dark),
              _buildMacroInfo('Gordura', '23/52g', 0.4, white, dark),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, double progress, Color color, Color dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: progress, backgroundColor: dark, color: color, minHeight: 3),
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Widget: Lista de Refeições
  Widget _buildMealItem(String title, String kcal, Color iconColor, Color textColor, Color kcalColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500))),
          Text(kcal, style: TextStyle(color: kcalColor, fontSize: 13)),
        ],
      ),
    );
  }

  // Widget: Gráfico Semanal 
  Widget _buildWeeklyChart(Color bg, Color accent, Color light, Color muted) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final heights = [0.6, 0.8, 0.5, 0.9, 0.7, 0.2, 0.2]; // Proporção da altura das barras

    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 25,
                height: 50 * heights[index],
                decoration: BoxDecoration(
                  color: index == 4 ? accent : bg, 
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: index == 4 ? accent : Colors.white10),
                ),
              ),
              const SizedBox(height: 8),
              Text(days[index], style: TextStyle(color: index == 4 ? light : muted, fontSize: 10)),
            ],
          );
        }),
      ),
    );
  }
}