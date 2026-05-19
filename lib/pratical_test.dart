import 'package:flutter/material.dart';
//import 'package:projeto/core/theme/app_colors.dart';
import 'package:nutri_scan/presentation/widgets/nutri_text_field.dart';
import 'package:nutri_scan/presentation/widgets/nutri_button.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PraticalTestPage(),
  ));
}

class PraticalTestPage extends StatelessWidget {
  const PraticalTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NutriScan UI Preview'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECÇÃO DE INPUTS ---
            const Text(
              'COMPONENTES DE TEXTO',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Divider(),
            const SizedBox(height: 20),
            
            const NutriTextField(
              label: 'Email',
              hint: 'introduza o seu email',
            ),
            
            
            const NutriTextField(
              label: 'Password',
              hint: '••••••••',
              //obscureText: true,
            ),

            const SizedBox(height: 40),

            // --- SECÇÃO DE BOTÕES ---
            const Text(
              'ESTILOS DE BOTÕES',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Botão Primário (Elevated)
            NutriButton(
              text: 'LOGIN',
              onPressed: () => debugPrint('Botão Primary Clicado'),
            ),
            
            const SizedBox(height: 16),

            // Botão Outline
            NutriButton(
              text: 'CRIAR CONTA',
              onPressed: () => debugPrint('Botão Outline Clicado'),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 30),
            
          ],
        ),
      ),
    );
  }
}