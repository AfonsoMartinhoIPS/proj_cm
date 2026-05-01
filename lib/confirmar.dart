import 'package:flutter/material.dart';
import 'package:proj_cm/registar.dart';
import 'dados.dart'; // Import para voltar e editar

class Confirmar extends StatelessWidget {
  const Confirmar({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Confirma os\nteus dados',
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Confirma os teus dados antes de criar a conta.',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Cartão de Resumo de Dados
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C4035),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4A6B54)),
                ),
                child: Column(
                  children: [
                    _buildDataRow('Nome', 'Ana Ferreira'),
                    _buildDataRow('Idade', '26 anos'),
                    _buildDataRow('Peso', 'Feminino'),
                    _buildDataRow('Altura', '168 cm'),
                    _buildDataRow('Objectivo', 'Perder Peso'),
                    _buildDataRow('Clorias', '1580 kcal'),
                    _buildDataRow('Atividade', 'Sedentário/a'),
                  ],
                ),
              ),
              
              const Spacer(), // Empurra os botões para o fundo

              // Botão Confirmar e Avançar
              ElevatedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registar()),
    );
  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF588157),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Criar Conta',
                  style: TextStyle(color: Color(0xFFDAD7CD), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Botão Editar
              OutlinedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DadosPessoais()),
    );
  },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A6B54)),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Editar dados',
                  style: TextStyle(color: Color(0xFFA3B18A), fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Color(0xFFDAD7CD), fontSize: 14, fontWeight: FontWeight.bold),
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
        '4 / 4',
        style: TextStyle(color: Color(0xFFA3B18A), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}