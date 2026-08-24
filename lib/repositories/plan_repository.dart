import '../core/database/app_database.dart';
import '../models/plan_model.dart';

/// Repository for handling Subscription Plans operations
class PlanRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<List<PlanModel>> getAllPlans() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query('plans', orderBy: 'id ASC');
    return maps.map((e) => PlanModel.fromMap(e)).toList();
  }

  Future<PlanModel?> getPlanById(int id) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plans',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PlanModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertPlan(PlanModel plan) async {
    final db = await _appDb.database;
    return await db.insert('plans', plan.toMap());
  }

  Future<int> updatePlan(PlanModel plan) async {
    final db = await _appDb.database;
    return await db.update(
      'plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> getTraineesCountForPlan(int planId) async {
    final db = await _appDb.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM trainees WHERE plan_id = ?',
      [planId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deletePlan(int id) async {
    final traineesCount = await getTraineesCountForPlan(id);
    if (traineesCount > 0) {
      throw Exception('لا يمكن حذف هذه الباقة لأن هناك $traineesCount متدرب مسجلين بها');
    }
    final db = await _appDb.database;
    return await db.delete(
      'plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
