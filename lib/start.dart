import 'package:flutter/material.dart';
import 'dados.dart';
import 'login.dart';

class WelcomeOnboard extends StatelessWidget {
  const WelcomeOnboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344E41),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(),
              // Icone Central com Emoji
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A5A40),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4A6B54), width: 3),
                  ),
                  child: const Center(
                    child: Text('🥗', style: TextStyle(fontSize: 50)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Título
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'DM Sans'),
                  children: [
                    TextSpan(text: 'Bem-vindo ao\n', style: TextStyle(color: Color(0xFFDAD7CD))),
                    TextSpan(text: 'NutriScan', style: TextStyle(color: Color(0xFFA3B18A))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              const Text(
                'A tua app de nutrição pessoal.\nMonitoriza, aprende e atinge os teus objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 30),

              // Tags de Funcionalidades
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildTag("Scan de produtos"),
                  _buildTag("Registo de refeições"),
                  _buildTag("Objetivos personalizados"),
                ],
              ),
              
              const Spacer(),

              // Botões de Ação
              ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DadosPessoais()),
    );
  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF588157),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Começar agora', style: TextStyle(color: Color(0xFFDAD7CD), fontSize: 16)),
              ),
              const SizedBox(height: 15),
              
              OutlinedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A6B54)),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Já tenho conta · Entrar', style: TextStyle(color: Color(0xFFA3B18A))),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C4035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A6B54)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: Color(0xFF588157)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFFA3B18A), fontSize: 11)),
        ],
      ),
    );
  }
}