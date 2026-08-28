import 'package:flutter/material.dart';
import '../constants/tactical_colors.dart';

class TacticalTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TacticalColors.backgroundBase,
      colorScheme: const ColorScheme.dark(
        primary: TacticalColors.cyanActive,
        secondary: TacticalColors.violetAux,
        surface: TacticalColors.surfaceBase,
        error: TacticalColors.crimsonCritical,
        onPrimary: TacticalColors.backgroundBase,
        onSecondary: Colors.white,
        onSurface: TacticalColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TacticalColors.surfaceBase,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: TacticalColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
        iconTheme: IconThemeData(color: TacticalColors.cyanActive),
      ),
      cardTheme: CardThemeData(
        color: TacticalColors.surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: TacticalColors.surfaceBorder, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: TacticalColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: TacticalColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: TacticalColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: TacticalColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: TacticalColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(
          color: TacticalColors.textSecondary,
          fontSize: 13,
        ),
        labelLarge: TextStyle(
          color: TacticalColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TacticalColors.surfaceBorder,
        thickness: 1,
      ),
    );
  }
}
