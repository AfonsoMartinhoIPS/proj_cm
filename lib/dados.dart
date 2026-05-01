import 'package:flutter/material.dart';
import 'objectivos.dart';

class DadosPessoais extends StatelessWidget {
  const DadosPessoais({super.key});

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
        child: SingleChildScrollView( // Permite fazer scroll quando o teclado abre
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Olá! Vamos\nconhecer-te',
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Precisamos de alguns dados para personalizar a tua experiência.',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Campo: Nome
              _buildInputField(label: 'Nome completo', hint: 'Ana Ferreira'),
              const SizedBox(height: 20),

              // Linha: Idade e Sexo
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Idade', hint: '26')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField(label: 'Sexo', hint: 'Feminino')),
                ],
              ),
              const SizedBox(height: 20),

              // Linha: Peso e Altura
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Peso (kg)', hint: '62', isSelected: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField(label: 'Altura (cm)', hint: '168')),
                ],
              ),
              
              const SizedBox(height: 40),

              // Botão Próximo
              ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Objetivos()),
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

  // Widget auxiliar para os campos de entrada
  Widget _buildInputField({required String label, required String hint, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFA3B18A) : const Color(0xFF4A6B54),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Color(0xFF6B8C74), fontSize: 10, fontWeight: FontWeight.bold),
          ),
          TextField(
            style: const TextStyle(color: Color(0xFFDAD7CD), fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF4A6B54)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para o indicador de progresso (1 / 4)
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A5A40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '1 / 4',
        style: TextStyle(color: Color(0xFFA3B18A), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}