import 'package:flutter/material.dart';

class TacticalColors {
  // Base backgrounds & surfaces (Near-black / Charcoal)
  static const Color backgroundBase = Color(0xFF0D1117);
  static const Color surfaceBase = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF21262D);
  static const Color surfaceBorder = Color(0xFF30363D);

  // Tactical accent palette
  static const Color cyanActive = Color(
    0xFF00F0FF,
  ); // Active broadcast / online
  static const Color cyanGlow = Color(0x3300F0FF);
  static const Color violetAux = Color(
    0xFF8A2BE2,
  ); // Secondary telemetry / group
  static const Color violetGlow = Color(0x338A2BE2);
  static const Color amberWarning = Color(
    0xFFFFB800,
  ); // Stale coordinates / warning
  static const Color crimsonCritical = Color(
    0xFFFF3B30,
  ); // Offline / emergency stop

  // Typography & Content
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF484F58);
  static const Color textMonospace = Color(0xFF58A6FF);
}
