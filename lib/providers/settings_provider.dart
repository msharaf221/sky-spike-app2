import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

/// State management for app branding, appearance & customization settings.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  SettingsModel _settings = SettingsModel.defaults();
  SettingsModel get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Material [ThemeMode] to hand to `MaterialApp`.
  ThemeMode get themeMode => _settings.themeMode.materialMode;

  /// Whether the dark palette should currently be active, resolving
  /// [AppThemeMode.system] against the platform brightness.
  bool get isDarkActive {
    switch (_settings.themeMode) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repo.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _applyPalette();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save(SettingsModel newSettings) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _repo.saveSettings(newSettings);
      _settings = newSettings;
      _applyPalette();
      return true;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Persist just the appearance mode (used by the quick toggle).
  Future<bool> setThemeMode(AppThemeMode mode) {
    return save(_settings.copyWith(themeMode: mode));
  }

  /// Cycle light -> dark -> system -> light.
  Future<bool> cycleThemeMode() {
    const order = [AppThemeMode.light, AppThemeMode.dark, AppThemeMode.system];
    final next = order[(order.indexOf(_settings.themeMode) + 1) % order.length];
    return setThemeMode(next);
  }

  Future<bool> reset() async {
    return save(SettingsModel.defaults());
  }

  /// Re-apply the currently persisted palette (used when leaving unsaved edits
  /// or when the platform brightness changes while on [AppThemeMode.system]).
  void reapplyFromStore() {
    _applyPalette();
    notifyListeners();
  }

  /// Preview an unsaved brand/appearance combination without persisting it.
  void previewPalette(SettingsModel draft) {
    AppPalette.isDark = _resolveDark(draft.themeMode);
    AppPalette.apply(primary: draft.primary, secondary: draft.secondary);
  }

  void _applyPalette() {
    AppPalette.isDark = isDarkActive;
    AppPalette.apply(
      primary: _settings.primary,
      secondary: _settings.secondary,
    );
  }

  bool _resolveDark(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
    }
  }
}
