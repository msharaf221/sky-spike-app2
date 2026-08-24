import '../core/database/app_database.dart';
import '../models/payment_model.dart';
import '../models/trainee_model.dart';

/// Repository for handling Financial records, Payments & Debts
class PaymentRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<List<PaymentModel>> getAllPayments() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT payments.*, trainees.name as trainee_name, trainees.group_name 
      FROM payments 
      LEFT JOIN trainees ON payments.trainee_id = trainees.id 
      ORDER BY payments.date DESC, payments.id DESC
    ''');
    return maps.map((e) => PaymentModel.fromMap(e)).toList();
  }

  Future<List<PaymentModel>> getPaymentsByTrainee(int traineeId) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'trainee_id = ?',
      whereArgs: [traineeId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((e) => PaymentModel.fromMap(e)).toList();
  }

  /// Record payment atomically & update trainee paid amount
  Future<int> recordPayment({
    required int traineeId,
    required double amount,
    required String date,
    required String paymentMethod,
    String? notes,
  }) async {
    final db = await _appDb.database;

    return await db.transaction((txn) async {
      final paymentId = await txn.insert('payments', {
        'trainee_id': traineeId,
        'amount': amount,
        'date': date,
        'payment_method': paymentMethod,
        'notes': notes,
      });

      // Update trainee's paid_amount
      await txn.rawUpdate('''
        UPDATE trainees 
        SET paid_amount = paid_amount + ? 
        WHERE id = ?
      ''', [amount, traineeId]);

      return paymentId;
    });
  }

  /// Delete payment and revert trainee's paid amount
  Future<void> deletePayment(int paymentId) async {
    final db = await _appDb.database;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> payments = await txn.query(
        'payments',
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      if (payments.isNotEmpty) {
        final payment = payments.first;
        final traineeId = payment['trainee_id'] as int;
        final amount = (payment['amount'] as num).toDouble();

        await txn.delete(
          'payments',
          where: 'id = ?',
          whereArgs: [paymentId],
        );

        await txn.rawUpdate('''
          UPDATE trainees 
          SET paid_amount = CASE 
            WHEN paid_amount >= ? THEN paid_amount - ? 
            ELSE 0 
          END 
          WHERE id = ?
        ''', [amount, amount, traineeId]);
      }
    });
  }

  /// Trainees with outstanding debts
  Future<List<TraineeModel>> getTraineesWithDebt() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      WHERE trainees.paid_amount < trainees.total_fee 
      ORDER BY (trainees.total_fee - trainees.paid_amount) DESC
    ''');
    return maps.map((e) => TraineeModel.fromMap(e)).toList();
  }

  /// Get total revenue for month prefix (e.g. '2026-08')
  Future<double> getMonthlyRevenue(String yearMonthPrefix) async {
    final db = await _appDb.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM payments 
      WHERE date LIKE ?
    ''', ['$yearMonthPrefix%']);

    final total = result.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }

  /// Get total outstanding debt across all active trainees
  Future<double> getTotalOutstandingDebt() async {
    final db = await _appDb.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_fee - paid_amount) as total_debt 
      FROM trainees 
      WHERE total_fee > paid_amount AND status = 'Active'
    ''');

    final debt = result.first['total_debt'];
    if (debt == null) return 0.0;
    return (debt as num).toDouble();
  }

  /// Total lifetime collected revenue
  Future<double> getTotalLifetimeRevenue() async {
    final db = await _appDb.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM payments');
    final total = result.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }
}
