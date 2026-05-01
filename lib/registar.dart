import 'package:flutter/material.dart';

class Registar extends StatelessWidget {
  const Registar({super.key});

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
                'Cria Conta',
                style: TextStyle(
                  color: Color(0xFFDAD7CD),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Regista-te para começar a monitorizar a tua nutrição.',
                style: TextStyle(color: Color(0xFF6B8C74), fontSize: 14),
              ),
              const SizedBox(height: 35),

              // Campo: Nome
              _buildInputField(
                label: 'Nome Completo',
                hint: 'Ana Ferreira',
                icon: Icons.person,
              ),

              const SizedBox(height: 20),
              // Campo: Email
              _buildInputField(
                label: 'Email',
                hint: 'exemplo@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Campo: Password
              _buildInputField(
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              // Campo: Confirmar Password
              _buildInputField(
                label: 'Confirmar Password',
                hint: '••••••••',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
              ),
              
              const SizedBox(height: 30),

              // Termos e Condições (Checkbox simulada)
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF4A6B54)),
                    ),
                    child: const Icon(Icons.check, size: 14, color: Color(0xFFA3B18A)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Aceito os Termos de Serviço e a Política de Privacidade.',
                      style: TextStyle(color: Color(0xFF6B8C74), fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Botão Registar
              ElevatedButton(
                onPressed: () {
                  // Ação de registo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF588157),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Registar',
                  style: TextStyle(
                    color: Color(0xFFDAD7CD),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os campos de texto
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6B8C74),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF2C4035),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4A6B54)),
          ),
          child: TextField(
            obscureText: isPassword,
            style: const TextStyle(color: Color(0xFFDAD7CD)),
            decoration: InputDecoration(
              icon: Icon(icon, color: const Color(0xFF588157), size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF4A6B54), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

}