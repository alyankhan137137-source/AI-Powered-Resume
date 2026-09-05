/// Spacing scale — never use raw numbers outside this set (see DESIGN_SYSTEM.md).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Only two radii exist in this app. Do not add a third.
class AppRadius {
  AppRadius._();

  static const double sm = 8; // inputs, buttons, chips
  static const double lg = 16; // cards, sheets, modals
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 400);
}
