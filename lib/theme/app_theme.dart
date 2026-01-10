import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFFFF742F);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightTextMain = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFE9ECEF);
  
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFFF742F);
  static const Color darkBackground = Color(0xFF0F0F0F); // Deeper black
  static const Color darkSurface = Color(0xFF1A1A1A); // Slightly lighter than background
  static const Color darkTextMain = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFADB5BD);
  static const Color darkBorder = Color(0xFF2D2D2D);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary,
      surface: lightSurface,
      onSurface: lightTextMain,
      outline: lightBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightTextMain,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: lightBorder),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextMain, fontSize: 16),
      bodyMedium: TextStyle(color: lightTextMain, fontSize: 14),
      bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkPrimary,
      surface: darkSurface,
      onSurface: darkTextMain,
      outline: darkBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextMain,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: darkBorder),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextMain, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextMain, fontSize: 14),
      bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
    ),
  );
}
