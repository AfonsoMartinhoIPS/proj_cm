import 'package:flutter/material.dart';
import 'home.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF344E41);
    const accentGreen = Color(0xFF588157);
    const lightSage = Color(0xFFA3B18A);
    const offWhite = Color(0xFFDAD7CD);
    const darkInput = Color(0xFF2C4035);
    const borderGreen = Color(0xFF4A6B54);

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo e Nome 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //child: const Icon(Icons., color: offWhite, size: 24), // meter o logo da app mais tarde
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nutri',
                          style: TextStyle(color: offWhite, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Scan',
                          style: TextStyle(color: lightSage, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Boas-vindas
              const Text(
                'Bem-vindo de volta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: offWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sessão para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: borderGreen,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // Campo de Email
              _buildTextField(
                label: 'Email',
                hint: 'ana@email.com',
                labelColor: borderGreen,
                inputColor: offWhite,
                backgroundColor: darkInput,
                borderColor: borderGreen,
              ),

              const SizedBox(height: 20),

              // Campo da Password
              _buildTextField(
                label: 'Password',
                hint: '••••••••',
                obscureText: true,
                labelColor: lightSage,
                inputColor: offWhite,
                backgroundColor: darkInput,
                borderColor: lightSage,
              ),

              // forgoten password?
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueceste a password?',
                    style: TextStyle(color: lightSage, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Botão Entrar
              ElevatedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: offWhite,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),

              const SizedBox(height: 32),

              //  "continua com"
              Row(
                children: [
                  const Expanded(child: Divider(color: borderGreen)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ou continua com', style: TextStyle(color: borderGreen, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: borderGreen)),
                ],
              ),

              const SizedBox(height: 32),

              // Botões Sociais (Google e Apple)
              Row(
                children: [
                  Expanded(child: _buildSocialButton('Google', lightSage, borderGreen)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSocialButton('Apple', lightSage, borderGreen)),
                ],
              ),

              const SizedBox(height: 40),

              // Registar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tens conta? ',
                    style: TextStyle(color: lightSage, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Registar',
                      style: TextStyle(color: offWhite, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para campos de texto consistentes
  Widget _buildTextField({
    required String label,
    required String hint,
    required Color labelColor,
    required Color inputColor,
    required Color backgroundColor,
    required Color borderColor,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          style: TextStyle(color: inputColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: inputColor.withOpacity(0.5)),
            filled: true,
            fillColor: backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para botões sociais
  Widget _buildSocialButton(String label, Color textColor, Color borderColor) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 14)),
    );
  }
}