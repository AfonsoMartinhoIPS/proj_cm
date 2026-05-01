import 'package:flutter/material.dart';
import 'dart:async';
import 'estimativa.dart';

class Calculo extends StatefulWidget {
  const Calculo({super.key});

  @override
  State<Calculo> createState() => _CalculoState();
}

class _CalculoState extends State<Calculo> {
 @override
void initState() {
  super.initState();
  Timer(const Duration(seconds: 4), () { // 4 segundos para dar tempo de ver a "animação"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Estimativa()),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344E41),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustração Central (Substituí os círculos do Figma por algo mais dinâmico)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x1E588157),
                      border: Border.all(color: const Color(0x2D588157), width: 2),
                    ),
                  ),
                  const Text(
                    '📊',
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA3B18A)),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Texto de Feedback
              const Text(
                'A calcular o teu plano...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Estamos a analisar os teus dados para criar metas de calorias e macros ideais para ti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B8C74),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 50),

              // Lista de "tarefas" a serem feitas (mantendo o conceito visual das tuas tags)
              _buildProcessingStep('Analisar perfil biométrico', true),
              _buildProcessingStep('Ajustar metas de peso', true),
              _buildProcessingStep('Finalizar recomendações', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingStep(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFFA3B18A) : const Color(0xFF4A6B54),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDone ? const Color(0xFFDAD7CD) : const Color(0xFF6B8C74),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}