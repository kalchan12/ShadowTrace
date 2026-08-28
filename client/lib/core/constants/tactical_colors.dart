import 'package:flutter/material.dart';

class TacticalColors {
  // Base Canvas & Surfaces (Neon Protocol)
  static const Color background = Color(0xFF0A0C10);
  static const Color surface = Color(0xFF111318);
  static const Color surfaceDim = Color(0xFF111318);
  static const Color surfaceBright = Color(0xFF37393E);
  static const Color surfaceContainerLowest = Color(0xFF0C0E12);
  static const Color surfaceContainerLow = Color(0xFF1A1C20);
  static const Color surfaceContainer = Color(0xFF1E2024);
  static const Color surfaceContainerHigh = Color(0xFF282A2E);
  static const Color surfaceContainerHighest = Color(0xFF333539);

  // Neon & Tactical Accents
  static const Color primary = Color(0xFFDBFCFF);
  static const Color primaryContainer = Color(0xFF00F0FF); // Electric Cyan
  static const Color primaryFixed = Color(0xFF7DF4FF);
  static const Color primaryFixedDim = Color(0xFF00DBE9);
  static const Color onPrimary = Color(0xFF00363A);
  static const Color onPrimaryContainer = Color(0xFF006970);

  // Secondary Accents (Violet & Tactical Blue)
  static const Color secondary = Color(0xFFD1BCFF);
  static const Color secondaryContainer = Color(0xFF7000FF);
  static const Color onSecondaryContainer = Color(0xFFDDCDFF);
  static const Color tacticalBlue = Color(0xFF2E5BFF);
  static const Color onTertiaryContainer = Color(0xFF124AF0);

  // Outlines & Borders
  static const Color outline = Color(0xFF849495);
  static const Color outlineVariant = Color(0xFF3B494B);
  static const Color borderHud = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)

  // Typography Colors
  static const Color onSurface = Color(0xFFE2E2E8);
  static const Color onSurfaceVariant = Color(0xFFB9CACB);
  static const Color onBackground = Color(0xFFE2E2E8);

  // Functional Alerts
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorCritical = Color(0xFFFF2E2E);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color warningAmber = Color(0xFFFFB800);

  // Glow Helpers
  static const Color glowCyan = Color(0x6600F0FF);
  static const Color glowViolet = Color(0x667000FF);

  // Backwards-Compatible Tactical Aliases
  static const Color backgroundBase = background;
  static const Color surfaceBase = surface;
  static const Color surfaceElevated = surfaceContainerHigh;
  static const Color surfaceBorder = outlineVariant;
  static const Color cyanActive = primaryContainer;
  static const Color cyanGlow = glowCyan;
  static const Color violetAux = secondaryContainer;
  static const Color violetGlow = glowViolet;
  static const Color amberWarning = warningAmber;
  static const Color crimsonCritical = errorCritical;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textTertiary = outline;
  static const Color textMonospace = primaryFixedDim;
}
