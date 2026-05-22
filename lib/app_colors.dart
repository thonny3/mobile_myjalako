import 'package:flutter/material.dart';

/// Palette alignée sur la maquette login (couleurs exactes de l'image).
class AppColors {
  AppColors._();

  // --- Maquette (hex exacts) ---
  static const Color creamBackground = Color(0xFFFDFCF9);
  static const Color mintSurface = Color(0xFFE8F5F1);
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFA0A0A0);
  static const Color fieldWhite = Color(0xFFFFFFFF);
  static const Color fieldBorder = Color(0xFFE0E0E0);

  /// Accent principal (corail maquette).
  static const Color accent = Color(0xFFFF5A5F);
  static const Color accentDark = Color(0xFFE0484D);
  static const Color accentLight = Color(0xFFFF7B7F);

  // --- Compatibilité écrans existants ---
  static const Color primaryGreen = accent;
  static const Color textPrimary = Color(0xFF1C2D11);
  static const Color textSecondary = Color(0xFF7F8E75);
  static const Color sage = Color(0xFF8E9A86);
  static const Color surfaceMuted = Color(0xFFF5F7F4);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
}
