// core/config/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Paleta de cores centralizada da aplicação.
///
/// Contém as cores de marca (comuns a ambos os temas), as cores específicas
/// dos temas claro e escuro, e as cores dos macronutrientes.
/// Todas as cores são utilizadas pelo [AppTheme] para construir os esquemas
/// de cores dinâmicos.
class AppColors {
  AppColors._();

  //    Cores de marca (comuns a ambos os temas)

  /// Cor primária (verde médio).
  static const primary = Color(0xFF588157);

  /// Cor de texto e ícones sobre a cor primária.
  static const onPrimary = Color(0xFFFFFFFF);

  /// Cor secundária (verde acinzentado claro).
  static const secondary = Color(0xFFA3B18A);

  /// Cor de texto sobre a cor secundária (verde escuro para melhor contraste).
  static const onSecondary = Color(0xFF1F2B20);

  /// Cor de erro (vermelho escuro).
  static const error = Color(0xFFD32F2F);

  /// Cor de texto e ícones sobre a cor de erro.
  static const onError = Color(0xFFFFFFFF);

  //    Tema Escuro

  /// Cor de fundo principal do tema escuro.
  static const darkBackground = Color(0xFF344E41);

  /// Cor de superfície (cartões, diálogos) no tema escuro.
  static const darkSurface = Color(0xFF3A5A40);

  /// Cor de superfície secundária (inputs, cartões elevados) no tema escuro.
  static const darkSurfaceVariant = Color(0xFF2C4035);

  /// Cor do texto principal no tema escuro.
  static const darkOnSurface = Color(0xFFDAD7CD);

  /// Cor do texto secundário no tema escuro (contraste ≥ 4.5:1).
  static const darkTextMuted = Color(0xFFA4B8A7);

  /// Cor das bordas no tema escuro.
  static const darkBorder = Color(0xFF5A7A64);

  /// Cor dos divisores no tema escuro.
  static const darkDivider = Color(0xFF5A7A64);

  //    Tema Claro

  /// Cor de fundo principal do tema claro (levemente esverdeado).
  static const lightBackground = Color(0xFFEDF2EA);

  /// Cor de superfície (cartões, diálogos) no tema claro.
  static const lightSurface = Color(0xFFFFFFFF);

  /// Cor de superfície secundária (inputs, cartões elevados) no tema claro.
  static const lightSurfaceVariant = Color(0xFFE0E8DB);

  /// Cor do texto principal no tema claro.
  static const lightOnSurface = Color(0xFF3A5A3A);

  /// Cor do texto secundário no tema claro.
  static const lightTextMuted = Color(0xFF5A7A5A);

  /// Cor das bordas no tema claro.
  static const lightBorder = Color(0xFFB0C0A8);

  /// Cor dos divisores no tema claro.
  static const lightDivider = Color(0xFFB0C0A8);

  //    Cores dos Macronutrientes (independentes do tema)

  /// Cor representativa da proteína.
  static const protein = Color(0xFF42A5F5);

  /// Cor representativa dos hidratos de carbono.
  static const carbs = Color(0xFFFFCA28);

  /// Cor representativa da gordura.
  static const fat = Color(0xFFEF5350);

  /// Cor representativa da água.
  static const water = Color(0xFF29B6F6);
}