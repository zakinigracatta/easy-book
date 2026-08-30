import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Dark Blue & Purple Luxury
  static const Color primary = Color(0xFF4F46E5); // Indigo/Purple
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFFA855F7); // Purple Glow
  static const Color gold = Color(0xFFF59E0B); // Amber / Gold Accent

  // Backgrounds
  static const Color bgLight = Color(0xFFF7F8FC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color glassBgLight = Color(0xEFFFFFFF);
  static const Color bgDark = Color(0xFF080C16);
  static const Color cardDark = Color(0xFF121828);
  static const Color glassBgDark = Color(0x2A1E293B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Borders
  static const Color glassBorderLight = Color(0x1F111827);
  static const Color glassBorderDark = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
