import 'package:flutter/material.dart';

/// Color tokens for the "Ink & Paper" design system.
/// See DESIGN_SYSTEM.md — do not introduce ad-hoc colors outside this file.
class AppColors {
  AppColors._();

  static const Color ink900 = Color(0xFF141A20);
  static const Color ink800 = Color(0xFF2D3748);
  static const Color ink600 = Color(0xFF4B5560);
  static const Color ink300 = Color(0xFF9AA3AC);

  static const Color paper = Color(0xFFF7F6F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E0DA);

  static const Color growth600 = Color(0xFF2E6E58);
  static const Color growth100 = Color(0xFFDCEBE4);

  static const Color signal500 = Color(0xFFB8622E);
  static const Color signal100 = Color(0xFFF3E3D6);

  static const Color error500 = Color(0xFFB3403A);

  // Dark/Glass Theme Colors
  static const Color darkBackground = Color(0xFF020617);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFD946EF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color errorState = Color(0xFFEF4444);

  /// Used only to tag AI-generated content inline (badge, border accent).
  static const aiTagDecoration = BoxDecoration(
    color: signal100,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
}
