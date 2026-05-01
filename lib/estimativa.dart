import 'package:flutter/material.dart';
import 'package:proj_cm/confirmar.dart';

class Estimativa extends StatelessWidget {
  const Estimativa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344E41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Seta para voltar atrás
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA3B18A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildStepIndicator(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              const SizedBox(height: 30),

              // Títulos
              const Text(
                'Os teus objetivos diários',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Calculados com base no teu perfil. Ajustáveis depois.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xFF6B8C74),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Cartão de Calorias Diárias
              _buildCalorieCard(),

              const SizedBox(height: 25),

              // Macronutrientes 
              Wrap(
                spacing: 10,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildMacroTag('Proteína', '150g', const Color(0xFFA3B18A)),
                  _buildMacroTag('Hidratos', '210g', const Color(0xFFA3B18A)),
                  _buildMacroTag('Gordura', '70g', const Color(0xFFA3B18A)),
                ],
              ),

              const Spacer(),

              // Botão Próximo
              ElevatedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Confirmar()),
    );
  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF588157),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(
                    color: Color(0xFFDAD7CD),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget do Bloco de Calorias
  Widget _buildCalorieCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF4A6B54)),
      ),
      child: const Column(
        children: [
          Text(
            '1580',
            style: TextStyle(
              color: Color(0xFFA3B18A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'DM Sans',
            ),
          ),
          Text(
            'kcal/dia',
            style: TextStyle(
              color: Color(0xFF6B8C74),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }

  // Widget para as tags de macronutrientes
  Widget _buildMacroTag(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A6B54)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF6B8C74), fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Indicador de Progresso (Passo 3 de 4)
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3A5A40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '3 / 4',
        style: TextStyle(
          color: Color(0xFFA3B18A),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}