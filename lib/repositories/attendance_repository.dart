import '../core/database/app_database.dart';
import '../models/attendance_model.dart';
import '../models/trainee_model.dart';

/// Data class for representing a row in the daily roll call screen
class RollCallItem {
  final TraineeModel trainee;
  String? currentStatus; // 'Present', 'Absent', 'Excused', or null

  RollCallItem({
    required this.trainee,
    this.currentStatus,
  });
}

/// Repository for Attendance and Daily Roll Call logic
class AttendanceRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  /// Load roll call items for a selected date and group
  Future<List<RollCallItem>> getRollCallSheet({
    required String date,
    required String groupName,
  }) async {
    final db = await _appDb.database;

    // 1. Get all active trainees in this group
    final List<Map<String, dynamic>> traineesMaps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE trainees.group_name = ? AND trainees.status = 'Active'
      ORDER BY trainees.name ASC
    ''', [groupName]);

    final trainees = traineesMaps.map((e) => TraineeModel.fromMap(e)).toList();

    if (trainees.isEmpty) return [];

    // 2. Get existing attendance for this date
    final List<Map<String, dynamic>> attendanceMaps = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );

    final Map<int, String> attendanceMap = {
      for (var row in attendanceMaps) row['trainee_id'] as int: row['status'] as String,
    };

    return trainees.map((t) {
      return RollCallItem(
        trainee: t,
        currentStatus: attendanceMap[t.id],
      );
    }).toList();
  }

  /// Save attendance batch & accurately synchronize `attended_sessions` count
  Future<void> saveRollCallBatch({
    required String date,
    required Map<int, String> traineeStatusMap,
  }) async {
    final db = await _appDb.database;

    await db.transaction((txn) async {
      for (final entry in traineeStatusMap.entries) {
        final traineeId = entry.key;
        final status = entry.value;

        // Upsert into attendance table
        await txn.rawInsert('''
          INSERT INTO attendance (trainee_id, date, status) 
          VALUES (?, ?, ?)
          ON CONFLICT(trainee_id, date) 
          DO UPDATE SET status = excluded.status
        ''', [traineeId, date, status]);

        // Recalculate total attended sessions for this trainee
        final result = await txn.rawQuery('''
          SELECT COUNT(*) as count 
          FROM attendance 
          WHERE trainee_id = ? AND status = 'Present'
        ''', [traineeId]);

        final actualAttended = (result.first['count'] as int?) ?? 0;

        await txn.update(
          'trainees',
          {'attended_sessions': actualAttended},
          where: 'id = ?',
          whereArgs: [traineeId],
        );
      }
    });
  }

  /// Get attendance history for a single trainee
  Future<List<AttendanceModel>> getTraineeAttendanceHistory(int traineeId) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'trainee_id = ?',
      whereArgs: [traineeId],
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceModel.fromMap(e)).toList();
  }

  /// Get today's attendance stats
  Future<Map<String, int>> getAttendanceStatsForDate(String date) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM attendance 
      WHERE date = ?
      GROUP BY status
    ''', [date]);

    int present = 0;
    int absent = 0;
    int excused = 0;

    for (var row in maps) {
      final status = row['status'] as String?;
      final count = row['count'] as int? ?? 0;
      if (status == 'Present') present = count;
      if (status == 'Absent') absent = count;
      if (status == 'Excused') excused = count;
    }

    return {
      'present': present,
      'absent': absent,
      'excused': excused,
      'total': present + absent + excused,
    };
  }
}
