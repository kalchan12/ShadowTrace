import 'package:flutter/material.dart';
import '../constants/tactical_colors.dart';

class TacticalTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TacticalColors.background,
      colorScheme: const ColorScheme.dark(
        primary: TacticalColors.primaryContainer,
        secondary: TacticalColors.secondaryContainer,
        surface: TacticalColors.surface,
        error: TacticalColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: TacticalColors.onSurface,
        onError: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xD9111318), // surface 85%
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: TacticalColors.primaryFixedDim,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: TacticalColors.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xD90D1117),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: TacticalColors.borderHud, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: TacticalColors.onSurface,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        headlineMedium: TextStyle(
          color: TacticalColors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        headlineSmall: TextStyle(
          color: TacticalColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.02,
        ),
        bodyLarge: TextStyle(
          color: TacticalColors.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: TacticalColors.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          fontFamily: 'monospace',
          color: TacticalColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TacticalColors.borderHud,
        thickness: 1,
      ),
    );
  }
}
