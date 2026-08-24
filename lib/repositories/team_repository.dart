import 'package:sqflite/sqflite.dart';
import '../core/constants/app_strings.dart';
import '../core/database/app_database.dart';
import '../models/team_model.dart';

/// CRUD + reorder + rename (cascades to `trainees.group_name`) for teams.
class TeamRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<List<TeamModel>> getAllTeams({bool activeOnly = false}) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'teams',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map(TeamModel.fromMap).toList();
  }

  Future<List<String>> getActiveTeamNames() async {
    final teams = await getAllTeams(activeOnly: true);
    if (teams.isEmpty) return List<String>.from(AppStrings.teams);
    return teams.map((t) => t.name).toList();
  }

  Future<int> insertTeam(TeamModel team) async {
    final db = await _appDb.database;
    final existing = await db.query(
      'teams',
      where: 'name = ?',
      whereArgs: [team.name.trim()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('يوجد فريق بنفس الاسم بالفعل');
    }
    return db.insert('teams', team.toMap());
  }

  /// Rename a team and rewrite `trainees.group_name` so existing members follow.
  Future<void> renameTeam(int id, String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw Exception('اسم الفريق مطلوب');

    final db = await _appDb.database;
    final clash = await db.query(
      'teams',
      where: 'name = ? AND id != ?',
      whereArgs: [trimmed, id],
      limit: 1,
    );
    if (clash.isNotEmpty) {
      throw Exception('يوجد فريق بنفس الاسم بالفعل');
    }

    await db.transaction((txn) async {
      await txn.update(
        'teams',
        {'name': trimmed},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (oldName != trimmed) {
        await txn.update(
          'trainees',
          {'group_name': trimmed},
          where: 'group_name = ?',
          whereArgs: [oldName],
        );
      }
    });
  }

  Future<void> setActive(int id, bool isActive) async {
    final db = await _appDb.database;
    await db.update(
      'teams',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorder(List<TeamModel> ordered) async {
    final db = await _appDb.database;
    final batch = db.batch();
    for (var i = 0; i < ordered.length; i++) {
      final team = ordered[i];
      if (team.id == null) continue;
      batch.update(
        'teams',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [team.id],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Returns trainee count assigned to this team name.
  Future<int> countTrainees(String teamName) async {
    final db = await _appDb.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM trainees WHERE group_name = ?',
      [teamName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete a team. Blocked when trainees still use the name.
  Future<void> deleteTeam(TeamModel team) async {
    if (team.id == null) return;
    final count = await countTrainees(team.name);
    if (count > 0) {
      throw Exception(
        'لا يمكن حذف الفريق لأن $count متدرب ما زالوا مسجلين به. عطّله أو انقلهم أولاً.',
      );
    }
    final db = await _appDb.database;
    await db.delete('teams', where: 'id = ?', whereArgs: [team.id]);
  }
}
