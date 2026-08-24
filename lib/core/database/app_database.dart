import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'seed_data.dart';

/// Database Manager with Relational Schema, Foreign Keys & Auto-Migration
class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sky_spike_academy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign keys constraint enforcement in SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Plans Table
    await db.execute('''
      CREATE TABLE plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sessions_count INTEGER NOT NULL,
        price REAL NOT NULL,
        duration_days INTEGER NOT NULL
      )
    ''');

    // 2. Trainees Table
    await db.execute('''
      CREATE TABLE trainees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        age INTEGER NOT NULL,
        group_name TEXT NOT NULL,
        plan_id INTEGER NOT NULL,
        total_sessions INTEGER NOT NULL,
        attended_sessions INTEGER NOT NULL DEFAULT 0,
        total_fee REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'Active',
        join_date TEXT NOT NULL,
        FOREIGN KEY (plan_id) REFERENCES plans (id) ON DELETE RESTRICT
      )
    ''');

    // 3. Attendance Table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainee_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (trainee_id) REFERENCES trainees (id) ON DELETE CASCADE,
        UNIQUE (trainee_id, date)
      )
    ''');

    // 4. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainee_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (trainee_id) REFERENCES trainees (id) ON DELETE CASCADE
      )
    ''');

    // 5. App Settings (branding / customization)
    await _createSettingsTable(db);

    // Insert rich mock seed data on initial creation
    await SeedData.insertInitialData(db);
  }

  /// Handle schema migrations from older app versions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSettingsTable(db);
    }
    if (oldVersion < 3) {
      // v3: dark mode + official logo asset columns.
      await _addColumnIfMissing(
        db,
        table: 'app_settings',
        column: 'use_logo_asset',
        definition: 'INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumnIfMissing(
        db,
        table: 'app_settings',
        column: 'theme_mode',
        definition: "TEXT NOT NULL DEFAULT 'light'",
      );
      // v3: rename legacy team / group names to the official ones.
      await _renameLegacyGroups(db);
    }
  }

  /// Add a column only when it is not already present (safe re-runs).
  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  /// Map old group labels onto the official Sky Spike team names.
  static const Map<String, String> _legacyGroupRenames = {
    'ناشئين أ': 'الناشئون أ',
    'ناشئين ب': 'الناشئون ب',
    'فريق الشباب': 'الشباب',
    'أكاديمية البراعم': 'البراعم',
  };

  Future<void> _renameLegacyGroups(Database db) async {
    final batch = db.batch();
    _legacyGroupRenames.forEach((oldName, newName) {
      batch.update(
        'trainees',
        {'group_name': newName},
        where: 'group_name = ?',
        whereArgs: [oldName],
      );
    });
    await batch.commit(noResult: true);
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        id INTEGER PRIMARY KEY,
        club_name TEXT NOT NULL,
        tagline TEXT NOT NULL,
        primary_color INTEGER NOT NULL,
        secondary_color INTEGER NOT NULL,
        icon_code TEXT NOT NULL,
        show_logo INTEGER NOT NULL DEFAULT 1,
        use_logo_asset INTEGER NOT NULL DEFAULT 1,
        theme_mode TEXT NOT NULL DEFAULT 'light'
      )
    ''');
  }

  /// Close Database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }

  /// Reset Database (Useful for debug/tests)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sky_spike_academy.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
    _database = await _initDB('sky_spike_academy.db');
  }
}
