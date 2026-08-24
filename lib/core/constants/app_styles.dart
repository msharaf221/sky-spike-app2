import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sky Spike Typography and Decoration Styles
///
/// Everything is exposed as a getter (not `const`) because the underlying
/// [AppColors] values change at runtime when the user switches between light
/// and dark mode or edits the brand colors from the Settings screen.
class AppStyles {
  // Headings
  static TextStyle get h1 => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Body Texts
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  // Numbers & Currency
  static TextStyle get numberBig => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );

  static TextStyle get numberMedium => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppColors.isDark ? 0.30 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get heroCardDecoration => BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static BoxDecoration get accentCardDecoration => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Input Field Decoration Helper
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primaryLight, size: 22)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.elevatedSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    );
  }
}
