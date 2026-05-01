import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para o Timer
import 'start.dart'; // Importa a nova página

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Inicia um contador de 3 segundos
    Timer(const Duration(seconds: 3), () {
      // Navega para a página de Welcome e remove a Splash da pilha
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeOnboard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344E41),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logótipo (o quadrado arredondado)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF588157),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.qr_code_scanner, // Placeholder para o teu ícone
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              // Nome da App 
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nutri',
                      style: TextStyle(
                        color: Color(0xFFDAD7CD),
                        fontSize: 32,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Scan',
                      style: TextStyle(
                        color: Color(0xFFA3B18A),
                        fontSize: 32,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Slogan
              const Text(
                'Come melhor. Vive melhor.',
                style: TextStyle(
                  color: Color(0xFF588157),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              
              // Barra de carregamento???
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5A40),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 0,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3B18A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}