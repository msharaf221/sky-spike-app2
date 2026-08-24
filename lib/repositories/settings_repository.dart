import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../models/settings_model.dart';

/// Repository handling app branding / customization settings (single row).
class SettingsRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<SettingsModel> getSettings() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) {
      return SettingsModel.defaults();
    }
    return SettingsModel.fromMap(maps.first);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final db = await _appDb.database;
    await db.insert(
      'app_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> resetSettings() async {
    await saveSettings(SettingsModel.defaults());
  }
}
