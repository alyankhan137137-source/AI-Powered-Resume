import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale for app UI (Inter). Resume *document* text uses
/// AppTypography.serif* instead — see DESIGN_SYSTEM.md section 2.
class AppTypography {
  AppTypography._();

  static TextStyle display = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMuted = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle bodyStrong = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.white70,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ---- Document (resume) typography — Source Serif 4 ----
  // These stay dark because they are used on white "paper" backgrounds in previews.

  static TextStyle serifName = GoogleFonts.sourceSerif4(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink900,
  );

  static TextStyle serifSectionHeading = GoogleFonts.sourceSerif4(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.ink900,
  );

  static TextStyle serifBody = GoogleFonts.sourceSerif4(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.ink900,
  );
}
