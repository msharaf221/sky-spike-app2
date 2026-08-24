import 'package:flutter/material.dart';

/// Sky Spike Theme Colors
/// Volleyball inspired: Deep Navy Blue & Energetic Sunset Orange
class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1A237E); // Deep Navy Blue
  static const Color primaryDark = Color(0xFF0D1452);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryContainer = Color(0xFFE8EAF6);

  // Secondary / Accent Palette
  static const Color secondary = Color(0xFFFF6F00); // Energetic Volleyball Orange
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryContainer = Color(0xFFFFF3E0);

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

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D1452), Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
