import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

/// State management for app branding & customization settings.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  SettingsModel _settings = SettingsModel.defaults();
  SettingsModel get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repo.getSettings();
      AppPalette.apply(
        primary: _settings.primary,
        secondary: _settings.secondary,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
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
      AppPalette.apply(
        primary: newSettings.primary,
        secondary: newSettings.secondary,
      );
      return true;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> reset() async {
    return save(SettingsModel.defaults());
  }

  /// Re-apply the currently persisted palette (used when leaving unsaved edits).
  void reapplyFromStore() {
    AppPalette.apply(
      primary: _settings.primary,
      secondary: _settings.secondary,
    );
  }
}
