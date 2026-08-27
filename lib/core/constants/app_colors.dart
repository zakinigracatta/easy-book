import 'package:flutter/material.dart';

/// Single source of truth for the Easy Book visual identity.
///
/// Keep brand colors separate from semantic status colors so screens do not
/// accidentally invent their own palette. Compatibility aliases are kept for
/// older screens while the UI is migrated to the unified design system.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryHover = Color(0xFF4338CA);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFFA855F7);
  static const Color secondary = Color(0xFF1E1B4B);
  static const Color gold = Color(0xFFD4AF37);

  // Light theme
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = surfaceLight;
  static const Color glassBgLight = Color(0xF2FFFFFF);
  static const Color glassBorderLight = Color(0xFFE5E7EB);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color shadowLight = Color(0x0D000000);

  // Dark theme
  static const Color backgroundDark = Color(0xFF080C16);
  static const Color surfaceDark = Color(0xFF121828);
  static const Color cardDark = surfaceDark;
  static const Color glassBgDark = Color(0x08FFFFFF);
  static const Color glassBorderDark = Color(0x14FFFFFF);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color shadowDark = Color(0x5E000000);

  // Compatibility aliases used by older screens.
  static const Color bgDark = backgroundDark;
  static const Color bgLight = backgroundLight;

  // Semantic status colors. Use only for state/feedback, not decoration.
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE7D38A), gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF192038), surfaceDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
