import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = AppColors.primary;
  static const Color lightBackground = AppColors.background;
  static const Color lightSurface = AppColors.white;
  static const Color lightTextMain = AppColors.textMain;
  static const Color lightTextSecondary = AppColors.textSecondary;
  static const Color lightBorder = Color(0xFFE9ECEF);
  
  // Dark Theme Colors
  static const Color darkPrimary = AppColors.primary;
  static const Color darkBackground = AppColors.darkBackground; // Now 0xFF0D0D0D
  static const Color darkSurface = AppColors.darkSurface;       // Now 0xFF1F2022
  static const Color darkTextMain = AppColors.white;
  static const Color darkTextSecondary = AppColors.textSecondary;
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
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: lightTextMain, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextMain, fontSize: 14),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
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
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: darkTextMain, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextMain, fontSize: 14),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
    ),
  );
}
