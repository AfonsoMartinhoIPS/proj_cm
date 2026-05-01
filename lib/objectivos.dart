import 'package:flutter/material.dart';
import 'calculo.dart';

class Objetivos extends StatefulWidget {
  const Objetivos({super.key});

  @override
  State<Objetivos> createState() => _ObjetivosState();
}

class _ObjetivosState extends State<Objetivos> {
  // Variável para controlar a seleção do peso
  String objetivoPeso = 'Perder'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344E41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA3B18A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildStepIndicator(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Quais os teus\nobjetivos?',
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Usamos estas informações para elaborar recomendações personalizadas.',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Secção: Peso
              const Text(
                'PESO',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              _buildWeightSelector(),
              
              const SizedBox(height: 30),

              // Secção: Outros Objetivos
              const Text(
                'OUTROS',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 15),
              _buildOptionTile('Melhorar desempenho desportivo', isSelected: true),
              _buildOptionTile('Criar hábitos mais saudáveis', isSelected: false),
              _buildOptionTile('Prevenir doenças relacionadas ao estilo de vida', isSelected: false),

              const SizedBox(height: 40),

              // Botão Próximo
              ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Calculo()),
    );
  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF588157),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(color: Color(0xFFDAD7CD), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o seletor de Perder/Manter/Ganhar
  Widget _buildWeightSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Perder', 'Manter', 'Ganhar'].map((option) {
          bool selected = objetivoPeso == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => objetivoPeso = option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF588157) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? const Color(0xFFDAD7CD) : const Color(0xFF6B8C74),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget para as opções de lista
  Widget _buildOptionTile(String title, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3A5A40) : const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? const Color(0xFFA3B18A) : const Color(0xFF4A6B54),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFA3B18A) : const Color(0xFFDAD7CD),
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? const Color(0xFF588157) : const Color(0xFF4A6B54),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A5A40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '2 / 4',
        style: TextStyle(color: Color(0xFFA3B18A), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}