import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent Colors (matching React --primary-color and --accent-color)
  static const Color primary = Color(0xFF4F46E5);       // Professional Deep Indigo
  static const Color primaryHover = Color(0xFF4338CA);
  static const Color accent = Color(0xFFA855F7);        // Electric Purple / Accent
  static const Color secondary = Color(0xFF1E1B4B);     // Midnight Indigo
  static const Color gold = Color(0xFFD4AF37);         // Gold Accent

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color glassBgLight = Color(0xFFF3F4F6);
  static const Color glassBorderLight = Color(0xFFE5E7EB);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color shadowLight = Color(0x0D000000); // rgba(0,0,0,0.05)

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF080C16);
  static const Color surfaceDark = Color(0xFF121828);
  static const Color cardDark = Color(0xFF121828);
  static const Color glassBgDark = Color(0x08FFFFFF);  // rgba(255,255,255,0.03)
  static const Color glassBorderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textMutedDark = Color(0xFFA3A3A3);
  static const Color shadowDark = Color(0x5E000000);   // rgba(0,0,0,0.37)

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF3E7E9), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF192038), Color(0xFF121828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
