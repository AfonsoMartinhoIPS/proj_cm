import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gestor de temas centralizado da aplicação.
/// 
/// Controla a geração dos temas claro ([light]) e escuro ([dark]) garantindo
/// a consistência visual através do ecossistema Material 3.
class AppTheme {
  AppTheme._();

  /// Retorna a configuração de tema para o modo claro.
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Retorna a configuração de tema para o modo escuro.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// Constrói um [ThemeData] unificado com base no [brightness] fornecido.
  /// 
  /// Centraliza as propriedades comuns e adapta os componentes dinamicamente
  /// consoante o modo (Light ou Dark) para evitar duplicação de código.
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: isDark ? AppColors.onPrimary : Colors.white,
      secondary: AppColors.secondary,
      surface: isDark ? AppColors.surface : Colors.grey[50],
      onSurface: isDark ? AppColors.onBackground : Colors.black87,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.background : Colors.white,
      dividerColor: isDark ? AppColors.border : Colors.grey[300],
      
      textTheme: _buildTextTheme(colorScheme.onSurface, isDark),

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? colorScheme.secondary : Colors.white),
        titleTextStyle: TextStyle(
          color: isDark ? colorScheme.onSurface : Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
        selectedItemColor: isDark ? colorScheme.secondary : colorScheme.primary,
        unselectedItemColor: isDark ? AppColors.textMuted : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.border : Colors.grey[300]!),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
        hintStyle: TextStyle(color: isDark ? AppColors.textMuted : Colors.grey[600]),
        labelStyle: TextStyle(color: isDark ? AppColors.textMuted : Colors.grey[800]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? AppColors.border : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? colorScheme.secondary : colorScheme.primary, 
            width: 2,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDark ? AppColors.border : colorScheme.primary),
          foregroundColor: isDark ? colorScheme.secondary : colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? colorScheme.secondary : colorScheme.primary,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) 
                ? (isDark ? colorScheme.secondary : colorScheme.primary) 
                : (isDark ? AppColors.textMuted : Colors.grey[400])),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) 
                ? colorScheme.primary.withValues(alpha: 0.5) 
                : (isDark ? AppColors.surfaceDark : Colors.grey[200])),
      ),
    );
  }

  /// Gera a tipografia customizada com base na cor principal do texto.
  /// 
  /// Usa os parênteses retos (e.g. [baseColor]) para criar hiperligações automáticas 
  /// na documentação gerada pelo gerador de docs do Dart.
  static TextTheme _buildTextTheme(Color baseColor, bool isDark) {
    return TextTheme(
      displaySmall:   TextStyle(color: baseColor, fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: baseColor, fontSize: 22, fontWeight: FontWeight.bold),
      titleLarge:     TextStyle(color: baseColor, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge:      TextStyle(color: baseColor, fontSize: 16),
      bodyMedium:     TextStyle(color: baseColor, fontSize: 14),
      bodySmall:      TextStyle(color: isDark ? AppColors.textMuted : Colors.grey[700], fontSize: 12),
      labelLarge:     const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}