import 'package:flutter/material.dart';

/// Sky Spike Theme Colors
/// Volleyball inspired: Deep Navy Blue & Energetic Sunset Orange.
///
/// Every color exposed by [AppColors] is a *getter* backed by [AppPalette] so
/// that both the brand colors (editable from the Settings screen) and the
/// neutral / semantic colors (which flip between light & dark mode) can change
/// at runtime without restarting the app.
class AppPalette {
  // ---------------------------------------------------------------------
  // Brand seed colors (persisted in settings)
  // ---------------------------------------------------------------------
  static const Color defaultPrimary = Color(0xFF0B2A5B); // Sky Spike Navy
  static const Color defaultSecondary = Color(0xFFFF6F00); // Spike Orange

  static Color _seedPrimary = defaultPrimary;
  static Color _seedSecondary = defaultSecondary;

  /// Whether the app is currently rendering the dark palette.
  static bool isDark = false;

  // ---------------------------------------------------------------------
  // Derived brand shades
  // ---------------------------------------------------------------------
  static Color primary = defaultPrimary;
  static Color primaryDark = const Color(0xFF071B3B);
  static Color primaryLight = const Color(0xFF2C4E86);
  static Color primaryContainer = const Color(0xFFE3E9F5);

  static Color secondary = defaultSecondary;
  static Color secondaryDark = const Color(0xFFB34E00);
  static Color secondaryLight = const Color(0xFFFF9C42);
  static Color secondaryContainer = const Color(0xFFFFF1E3);

  static Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;

  static Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount)!;

  /// Relative luminance helper used to keep brand colors readable on dark
  /// backgrounds (a very dark navy is unreadable on a near-black surface).
  static Color _ensureReadableOnDark(Color color) {
    var result = color;
    var guard = 0;
    while (result.computeLuminance() < 0.30 && guard < 12) {
      result = _tint(result, 0.14);
      guard++;
    }
    return result;
  }

  /// Apply a new brand color pair and refresh every derived shade/container.
  ///
  /// Pass [dark] to also switch the neutral & semantic palette.
  static void apply({
    required Color primary,
    required Color secondary,
    bool? dark,
  }) {
    _seedPrimary = primary;
    _seedSecondary = secondary;
    if (dark != null) isDark = dark;

    final basePrimary = isDark ? _ensureReadableOnDark(primary) : primary;
    final baseSecondary = isDark ? _ensureReadableOnDark(secondary) : secondary;

    AppPalette.primary = basePrimary;
    AppPalette.secondary = baseSecondary;

    if (isDark) {
      AppPalette.primaryDark = _shade(basePrimary, 0.28);
      AppPalette.primaryLight = _tint(basePrimary, 0.22);
      AppPalette.primaryContainer = _shade(basePrimary, 0.62);

      AppPalette.secondaryDark = _shade(baseSecondary, 0.28);
      AppPalette.secondaryLight = _tint(baseSecondary, 0.22);
      AppPalette.secondaryContainer = _shade(baseSecondary, 0.62);
    } else {
      AppPalette.primaryDark = _shade(basePrimary, 0.35);
      AppPalette.primaryLight = _tint(basePrimary, 0.18);
      AppPalette.primaryContainer = _tint(basePrimary, 0.90);

      AppPalette.secondaryDark = _shade(baseSecondary, 0.35);
      AppPalette.secondaryLight = _tint(baseSecondary, 0.18);
      AppPalette.secondaryContainer = _tint(baseSecondary, 0.90);
    }
  }

  /// Flip between the light & dark neutral palettes, keeping the brand seeds.
  static void setDark(bool value) {
    isDark = value;
    apply(primary: _seedPrimary, secondary: _seedSecondary);
  }

  static void reset() {
    isDark = false;
    apply(primary: defaultPrimary, secondary: defaultSecondary);
  }
}

/// Light / dark neutral & semantic swatches.
class _Swatches {
  // Neutral & background
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color darkBackground = Color(0xFF0E1420);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF171E2C);

  static const Color lightSurfaceVariant = Color(0xFFEEF2F6);
  static const Color darkSurfaceVariant = Color(0xFF212A3B);

  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color darkDivider = Color(0xFF2C3648);

  // Typography
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color darkTextSecondary = Color(0xFFB4C0D3);

  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF7C8AA1);

  // Semantic
  static const Color lightSuccess = Color(0xFF2E7D32);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color lightSuccessContainer = Color(0xFFE8F5E9);
  static const Color darkSuccessContainer = Color(0xFF1B3320);

  static const Color lightWarning = Color(0xFFF57C00);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color lightWarningContainer = Color(0xFFFFF8E1);
  static const Color darkWarningContainer = Color(0xFF3A2E15);

  static const Color lightError = Color(0xFFC62828);
  static const Color darkError = Color(0xFFEF5350);
  static const Color lightErrorContainer = Color(0xFFFFEBEE);
  static const Color darkErrorContainer = Color(0xFF3A1D1F);

  static const Color lightInfo = Color(0xFF0288D1);
  static const Color darkInfo = Color(0xFF4FC3F7);
  static const Color lightInfoContainer = Color(0xFFE1F5FE);
  static const Color darkInfoContainer = Color(0xFF13303D);
}

class AppColors {
  static bool get isDark => AppPalette.isDark;

  static Color _pick(Color light, Color dark) =>
      AppPalette.isDark ? dark : light;

  // Primary Palette (dynamic)
  static Color get primary => AppPalette.primary;
  static Color get primaryDark => AppPalette.primaryDark;
  static Color get primaryLight => AppPalette.primaryLight;
  static Color get primaryContainer => AppPalette.primaryContainer;

  // Secondary / Accent Palette (dynamic)
  static Color get secondary => AppPalette.secondary;
  static Color get secondaryDark => AppPalette.secondaryDark;
  static Color get secondaryLight => AppPalette.secondaryLight;
  static Color get secondaryContainer => AppPalette.secondaryContainer;

  // Neutral & Background
  static Color get background =>
      _pick(_Swatches.lightBackground, _Swatches.darkBackground);
  static Color get surface => _pick(_Swatches.lightSurface, _Swatches.darkSurface);
  static Color get surfaceVariant =>
      _pick(_Swatches.lightSurfaceVariant, _Swatches.darkSurfaceVariant);
  static Color get cardColor => surface;
  static Color get divider =>
      _pick(_Swatches.lightDivider, _Swatches.darkDivider);

  /// Surface used for chips / inputs that must stand out from [surface].
  static Color get elevatedSurface =>
      _pick(_Swatches.lightSurface, _Swatches.darkSurfaceVariant);

  // Typography
  static Color get textPrimary =>
      _pick(_Swatches.lightTextPrimary, _Swatches.darkTextPrimary);
  static Color get textSecondary =>
      _pick(_Swatches.lightTextSecondary, _Swatches.darkTextSecondary);
  static Color get textMuted =>
      _pick(_Swatches.lightTextMuted, _Swatches.darkTextMuted);
  static Color get textOnPrimary => const Color(0xFFFFFFFF);

  // Status & Semantic Colors
  static Color get success =>
      _pick(_Swatches.lightSuccess, _Swatches.darkSuccess);
  static Color get successContainer =>
      _pick(_Swatches.lightSuccessContainer, _Swatches.darkSuccessContainer);
  static Color get warning =>
      _pick(_Swatches.lightWarning, _Swatches.darkWarning);
  static Color get warningContainer =>
      _pick(_Swatches.lightWarningContainer, _Swatches.darkWarningContainer);
  static Color get error => _pick(_Swatches.lightError, _Swatches.darkError);
  static Color get errorContainer =>
      _pick(_Swatches.lightErrorContainer, _Swatches.darkErrorContainer);
  static Color get info => _pick(_Swatches.lightInfo, _Swatches.darkInfo);
  static Color get infoContainer =>
      _pick(_Swatches.lightInfoContainer, _Swatches.darkInfoContainer);

  // Attendance Specific Colors
  static Color get present => success;
  static Color get absent => error;
  static Color get excused => warning;

  // Gradients (recomputed from the active palette)
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => LinearGradient(
        colors: [secondary, secondaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get heroGradient => LinearGradient(
        colors: [primaryDark, primary, primaryLight],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
}
