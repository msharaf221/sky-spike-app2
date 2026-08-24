import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';

/// Available logo / icon styles for the academy.
class AppIconOption {
  final String code;
  final String label;
  final IconData icon;

  const AppIconOption({
    required this.code,
    required this.label,
    required this.icon,
  });
}

class SettingsIcons {
  static const List<AppIconOption> options = [
    AppIconOption(code: 'volleyball', label: 'كرة الطائرة', icon: Icons.sports_volleyball),
    AppIconOption(code: 'groups', label: 'مجموعة', icon: Icons.groups),
    AppIconOption(code: 'shield', label: 'درع', icon: Icons.shield),
    AppIconOption(code: 'trophy', label: 'كأس', icon: Icons.emoji_events),
    AppIconOption(code: 'star', label: 'نجمة', icon: Icons.star_rounded),
    AppIconOption(code: 'flash', label: 'برق', icon: Icons.flash_on),
    AppIconOption(code: 'school', label: 'أكاديمية', icon: Icons.school),
    AppIconOption(code: 'local_activity', label: 'تذكرة', icon: Icons.local_activity),
    AppIconOption(code: 'sports_handball', label: 'كرة يد', icon: Icons.sports_handball),
    AppIconOption(code: 'people', label: 'لاعبون', icon: Icons.people),
  ];

  static IconData iconFor(String code) {
    for (final option in options) {
      if (option.code == code) return option.icon;
    }
    return options.first.icon;
  }

  static String labelFor(String code) {
    for (final option in options) {
      if (option.code == code) return option.label;
    }
    return options.first.label;
  }
}

/// Selectable app appearance modes.
enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  String get code {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.light:
        return AppStrings.themeLight;
      case AppThemeMode.dark:
        return AppStrings.themeDark;
      case AppThemeMode.system:
        return AppStrings.themeSystem;
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  ThemeMode get materialMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromCode(String? code) {
    switch (code) {
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }
}

/// App branding & customization settings (club / group / team details).
class SettingsModel {
  final String clubName;
  final String tagline;
  final int primaryColor;
  final int secondaryColor;
  final String iconCode;
  final bool showLogo;

  /// Use the official Sky Spike logo asset instead of a Material icon.
  final bool useLogoAsset;

  /// Light / dark / follow-system appearance.
  final AppThemeMode themeMode;

  const SettingsModel({
    required this.clubName,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.iconCode,
    required this.showLogo,
    required this.useLogoAsset,
    required this.themeMode,
  });

  factory SettingsModel.defaults() {
    return const SettingsModel(
      clubName: AppStrings.appName,
      tagline: AppStrings.appTagline,
      primaryColor: 0xFF0B2A5B,
      secondaryColor: 0xFFFF6F00,
      iconCode: 'volleyball',
      showLogo: true,
      useLogoAsset: true,
      themeMode: AppThemeMode.light,
    );
  }

  Color get primary => Color(primaryColor);
  Color get secondary => Color(secondaryColor);
  IconData get icon => SettingsIcons.iconFor(iconCode);
  String get iconLabel => SettingsIcons.labelFor(iconCode);

  SettingsModel copyWith({
    String? clubName,
    String? tagline,
    int? primaryColor,
    int? secondaryColor,
    String? iconCode,
    bool? showLogo,
    bool? useLogoAsset,
    AppThemeMode? themeMode,
  }) {
    return SettingsModel(
      clubName: clubName ?? this.clubName,
      tagline: tagline ?? this.tagline,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      iconCode: iconCode ?? this.iconCode,
      showLogo: showLogo ?? this.showLogo,
      useLogoAsset: useLogoAsset ?? this.useLogoAsset,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'club_name': clubName,
      'tagline': tagline,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'icon_code': iconCode,
      'show_logo': showLogo ? 1 : 0,
      'use_logo_asset': useLogoAsset ? 1 : 0,
      'theme_mode': themeMode.code,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    final defaults = SettingsModel.defaults();
    return SettingsModel(
      clubName: (map['club_name'] as String?) ?? defaults.clubName,
      tagline: (map['tagline'] as String?) ?? defaults.tagline,
      primaryColor: (map['primary_color'] as int?) ?? defaults.primaryColor,
      secondaryColor: (map['secondary_color'] as int?) ?? defaults.secondaryColor,
      iconCode: (map['icon_code'] as String?) ?? defaults.iconCode,
      showLogo: (map['show_logo'] as int? ?? 1) == 1,
      useLogoAsset: (map['use_logo_asset'] as int? ?? 1) == 1,
      themeMode: AppThemeModeX.fromCode(map['theme_mode'] as String?),
    );
  }
}
