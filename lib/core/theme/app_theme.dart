import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  // Dark Theme Constants (from Auth Flow)
  static const Color darkBackground = AppColors.darkBackground;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color primaryPurple = AppColors.primaryPurple;
  static const Color primaryPink = AppColors.primaryPink;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color errorState = AppColors.errorState;

  static const Color primaryBrand = primaryPurple;
  static const Color typographySecondary = textSecondary;

  static BoxDecoration mainBackground = const BoxDecoration(color: darkBackground);
  static BoxDecoration auraGradient = BoxDecoration(
    gradient: RadialGradient(
      center: const Alignment(0, -0.5),
      radius: 1.2,
      colors: [primaryPurple.withValues(alpha: 0.15), Colors.transparent],
    ),
  );
  static BoxDecoration glassButton = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryPurple, primaryPink],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.03),
    borderRadius: const BorderRadius.all(Radius.circular(24)),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.growth600,
      primary: AppColors.growth600,
      onPrimary: AppColors.surface,
      surface: AppColors.surface,
      error: AppColors.error500,
      brightness: Brightness.light,
    ),
    fontFamily: AppTypography.body.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTypography.display,
      titleLarge: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodyMuted,
      labelLarge: AppTypography.label,
      bodySmall: AppTypography.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.ink900),
      titleTextStyle: AppTypography.title,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        side: BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.growth600,
        foregroundColor: AppColors.surface,
        disabledBackgroundColor: AppColors.ink300,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
        textStyle: AppTypography.button,
        elevation: 0,
        animationDuration: AppDurations.fast,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink900,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.growth600,
        textStyle: AppTypography.bodyStrong,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: AppColors.growth600, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: AppColors.error500),
      ),
      labelStyle: AppTypography.label,
      hintStyle: AppTypography.bodyMuted,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.growth100,
      labelStyle: AppTypography.label.copyWith(color: AppColors.growth600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.growth600,
      linearTrackColor: AppColors.border,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPink,
      surface: surfaceDark,
      error: errorState,
      onSurface: textPrimary,
    ),
    fontFamily: AppTypography.body.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTypography.display.copyWith(color: textPrimary, fontWeight: FontWeight.w900, fontSize: 40, letterSpacing: -1.5),
      titleLarge: AppTypography.title.copyWith(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5),
      bodyLarge: AppTypography.body.copyWith(color: textSecondary, fontSize: 18, height: 1.6),
      bodyMedium: AppTypography.bodyMuted.copyWith(color: textSecondary, fontSize: 16, height: 1.5),
      labelLarge: AppTypography.label.copyWith(color: textPrimary),
      bodySmall: AppTypography.caption.copyWith(color: textSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.03),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      margin: const EdgeInsets.all(0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.zero,
        elevation: 0,
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.1), thickness: 1, space: 1),
  );
}
