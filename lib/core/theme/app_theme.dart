import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData get light => _lightThemeData();
  static ThemeData get dark  => _darkThemeData();

  static ThemeData _lightThemeData() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white, // Text on primary color
      secondary: AppColors.secondary,
      surface: Colors.grey[50], // Card/input background
      onSurface: Colors.black87, // Text on surface color
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary, // Light theme app bar background
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[100],
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: TextStyle(color: Colors.grey[800]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    textTheme: TextTheme(
      displaySmall:   TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
      titleLarge:     TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge:      TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium:     TextStyle(color: Colors.black87, fontSize: 14),
      bodySmall:      TextStyle(color: Colors.grey[700],    fontSize: 12),
      labelLarge:     TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), // For buttons
    ),
    dividerColor: Colors.grey[300],
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary : Colors.grey[400]),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary.withValues(alpha: 0.5) : Colors.grey[200]),
    ),
  );

  static ThemeData _darkThemeData() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary, // Use AppColors.onPrimary for consistency
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.onBackground,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.secondary),
      titleTextStyle: const TextStyle(
        color: AppColors.onBackground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary, // Use AppColors.onPrimary for consistency
        minimumSize: const Size(double.infinity, 50), // Consider making button height configurable or using a fixed value
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border), // Use AppColors.border for consistency
        foregroundColor: AppColors.secondary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary), // Use colorScheme.secondary
    ),
    textTheme: TextTheme(
      displaySmall:   TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.onBackground, fontSize: 22, fontWeight: FontWeight.bold),
      titleLarge:     TextStyle(color: AppColors.onBackground, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge:      TextStyle(color: AppColors.onBackground, fontSize: 16),
      bodyMedium:     TextStyle(color: AppColors.onBackground, fontSize: 14),
      bodySmall:      TextStyle(color: AppColors.textMuted,    fontSize: 12), // Muted text for dark theme
      labelLarge:     TextStyle(color: AppColors.onPrimary, fontSize: 14, fontWeight: FontWeight.w600), // For buttons
    ),
    dividerColor: AppColors.border,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.secondary : AppColors.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary : AppColors.surfaceDark),
    ),
  );
}
