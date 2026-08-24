import 'package:flutter/material.dart';

/// Sky Spike Theme Colors
/// Volleyball inspired: Deep Navy Blue & Energetic Sunset Orange.
///
/// Primary / secondary brand colors are dynamic so they can be edited from
/// the Settings screen. Neutral, text and semantic colors remain static.
class AppPalette {
  static Color primary = const Color(0xFF1A237E); // Deep Navy Blue
  static Color primaryDark = const Color(0xFF0D1452);
  static Color primaryLight = const Color(0xFF3949AB);
  static Color primaryContainer = const Color(0xFFE8EAF6);

  static Color secondary = const Color(0xFFFF6F00); // Energetic Volleyball Orange
  static Color secondaryDark = const Color(0xFFE65100);
  static Color secondaryLight = const Color(0xFFFFB74D);
  static Color secondaryContainer = const Color(0xFFFFF3E0);

  static Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;

  static Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount)!;

  /// Apply a new brand color pair and refresh the derived shades/containers.
  static void apply({required Color primary, required Color secondary}) {
    AppPalette.primary = primary;
    AppPalette.primaryDark = _shade(primary, 0.35);
    AppPalette.primaryLight = _tint(primary, 0.18);
    AppPalette.primaryContainer = _tint(primary, 0.9);

    AppPalette.secondary = secondary;
    AppPalette.secondaryDark = _shade(secondary, 0.35);
    AppPalette.secondaryLight = _tint(secondary, 0.18);
    AppPalette.secondaryContainer = _tint(secondary, 0.9);
  }

  static void reset() {
    apply(
      primary: const Color(0xFF1A237E),
      secondary: const Color(0xFFFF6F00),
    );
  }
}

class AppColors {
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
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F6);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Semantic Colors
  static const Color success = Color(0xFF2E7D32); // Green for Present / Fully Paid
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00); // Amber for Excused / Partial Payment
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828); // Red for Absent / Overdue Debt
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1); // Cyan/Blue for Notes/Details
  static const Color infoContainer = Color(0xFFE1F5FE);

  // Attendance Specific Colors
  static const Color present = Color(0xFF2E7D32);
  static const Color absent = Color(0xFFC62828);
  static const Color excused = Color(0xFFF57C00);

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
