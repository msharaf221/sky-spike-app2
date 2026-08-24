import 'package:sqflite/sqflite.dart';
import '../core/constants/app_strings.dart';
import '../core/database/app_database.dart';
import '../models/trainee_model.dart';

/// Repository for handling Trainees CRUD, Filtering, and Subscriptions
class TraineeRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<List<TraineeModel>> getAllTrainees({
    String? searchQuery,
    String? groupFilter,
    String? statusFilter,
    String? paymentFilter,
  }) async {
    final db = await _appDb.database;

    String sql = '''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE 1=1
    ''';
    final List<dynamic> args = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      sql += ' AND (trainees.name LIKE ? OR trainees.phone LIKE ?)';
      final query = '%${searchQuery.trim()}%';
      args.add(query);
      args.add(query);
    }

    if (groupFilter != null && groupFilter != 'الكل' && groupFilter.isNotEmpty) {
      sql += ' AND trainees.group_name = ?';
      args.add(groupFilter);
    }

    if (statusFilter != null && statusFilter != 'الكل' && statusFilter.isNotEmpty) {
      // Status mapping
      String dbStatus = statusFilter;
      if (statusFilter == 'نشط') dbStatus = 'Active';
      if (statusFilter == 'موقوف') dbStatus = 'Suspended';
      if (statusFilter == 'منتهي') dbStatus = 'Expired';
      sql += ' AND trainees.status = ?';
      args.add(dbStatus);
    }

    if (paymentFilter != null && paymentFilter != 'الكل' && paymentFilter.isNotEmpty) {
      if (paymentFilter == 'مسدد بالكامل') {
        sql += ' AND trainees.paid_amount >= trainees.total_fee';
      } else if (paymentFilter == 'عليه مديونية') {
        sql += ' AND trainees.paid_amount < trainees.total_fee';
      }
    }

    sql += ' ORDER BY trainees.id DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((e) => TraineeModel.fromMap(e)).toList();
  }

  Future<TraineeModel?> getTraineeById(int id) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE trainees.id = ?
      LIMIT 1
    ''', [id]);

    if (maps.isNotEmpty) {
      return TraineeModel.fromMap(maps.first);
    }
    return null;
  }

  /// Add trainee with optional initial payment inside an atomic transaction
  Future<int> insertTrainee(
    TraineeModel trainee, {
    double initialPayment = 0.0,
    String paymentMethod = 'Cash',
    String? notes,
  }) async {
    final db = await _appDb.database;

    return await db.transaction((txn) async {
      final traineeData = trainee.toMap();
      traineeData['paid_amount'] = initialPayment;

      final traineeId = await txn.insert('trainees', traineeData);

      if (initialPayment > 0) {
        await txn.insert('payments', {
          'trainee_id': traineeId,
          'amount': initialPayment,
          'date': trainee.joinDate,
          'payment_method': paymentMethod,
          'notes': notes ?? 'دفعة أولى عند التسجيل',
        });
      }

      return traineeId;
    });
  }

  Future<int> updateTrainee(TraineeModel trainee) async {
    final db = await _appDb.database;
    return await db.update(
      'trainees',
      trainee.toMap(),
      where: 'id = ?',
      whereArgs: [trainee.id],
    );
  }

  Future<int> deleteTrainee(int id) async {
    final db = await _appDb.database;
    return await db.delete(
      'trainees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Renew Subscription: Extends total sessions & total fee, records any payment made
  Future<void> renewSubscription({
    required int traineeId,
    required int planId,
    required double planPrice,
    required int sessionsCount,
    required double paidAmount,
    required String paymentMethod,
    required String date,
    String? notes,
  }) async {
    final db = await _appDb.database;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> res = await txn.query(
        'trainees',
        where: 'id = ?',
        whereArgs: [traineeId],
      );
      if (res.isEmpty) return;

      final current = TraineeModel.fromMap(res.first);
      final newTotalSessions = current.totalSessions + sessionsCount;
      final newTotalFee = current.totalFee + planPrice;
      final newPaidAmount = current.paidAmount + paidAmount;

      await txn.update(
        'trainees',
        {
          'plan_id': planId,
          'total_sessions': newTotalSessions,
          'total_fee': newTotalFee,
          'paid_amount': newPaidAmount,
          'status': 'Active',
        },
        where: 'id = ?',
        whereArgs: [traineeId],
      );

      if (paidAmount > 0) {
        await txn.insert('payments', {
          'trainee_id': traineeId,
          'amount': paidAmount,
          'date': date,
          'payment_method': paymentMethod,
          'notes': notes ?? 'تجديد اشتراك',
        });
      }
    });
  }

  /// Distinct groups for dropdowns & filters
  Future<List<String>> getDistinctGroups() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT group_name FROM trainees WHERE group_name IS NOT NULL AND group_name != "" ORDER BY group_name ASC',
    );
    final groups = maps.map((e) => e['group_name'] as String).toList();
    if (groups.isEmpty) {
      return List<String>.from(AppStrings.teams);
    }
    return groups;
  }

  /// Get trainees with 0 remaining sessions (for Dashboard Alert)
  Future<List<TraineeModel>> getZeroSessionsTrainees() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE (trainees.total_sessions - trainees.attended_sessions) <= 0 
        AND trainees.status = 'Active'
      ORDER BY trainees.name ASC
    ''');
    return maps.map((e) => TraineeModel.fromMap(e)).toList();
  }

  /// Get trainees with unpaid debt (for Dashboard Alert)
  Future<List<TraineeModel>> getUnpaidDebtTrainees() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE trainees.paid_amount < trainees.total_fee 
        AND trainees.status = 'Active'
      ORDER BY (trainees.total_fee - trainees.paid_amount) DESC
    ''');
    return maps.map((e) => TraineeModel.fromMap(e)).toList();
  }
}
