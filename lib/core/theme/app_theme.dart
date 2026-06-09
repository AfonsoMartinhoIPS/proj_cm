// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Gestor de temas centralizado da aplicação.
///
/// Gera os temas claro ([light]) e escuro ([dark]) com base nas constantes
/// definidas em [AppColors], garantindo consistência Material 3.
class AppTheme {
  AppTheme._();

  /// Tema claro (light mode).
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Tema escuro (dark mode).
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// Constrói um [ThemeData] completo a partir das cores semânticas.
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      surfaceContainerHighest: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      outlineVariant: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      error: AppColors.error,
      onError: AppColors.onError,
    );

    final textTheme = _buildTextTheme(
      baseColor: colorScheme.onSurface,
      mutedColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      dividerColor: colorScheme.outlineVariant,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? colorScheme.secondary : colorScheme.onPrimary,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary),
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary.withValues(alpha: 0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }

  /// Gera a tipografia com base nas cores do tema.
  static TextTheme _buildTextTheme({
    required Color baseColor,
    required Color mutedColor,
  }) {
    return TextTheme(
      displaySmall: TextStyle(
        color: baseColor,
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: baseColor,
        fontSize: AppSizes.fontXxl,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: baseColor,
        fontSize: AppSizes.fontXl,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: baseColor, fontSize: AppSizes.fontMd),
      bodyMedium: TextStyle(color: baseColor, fontSize: AppSizes.fontSm),
      bodySmall: TextStyle(color: mutedColor, fontSize: AppSizes.fontXs),
      labelLarge: const TextStyle(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}