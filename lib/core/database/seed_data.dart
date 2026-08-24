import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

/// Seed initial mock data for immediate out-of-the-box testing
class SeedData {
  static Future<void> insertInitialData(Database db) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    final twoDaysAgo = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 2)));

    // 0. Official teams (schema v4) — editable later from Settings.
    const teams = [
      'البراعم',
      'الناشئون أ',
      'الناشئون ب',
      'الشباب',
      'الفريق الأول',
    ];
    for (var i = 0; i < teams.length; i++) {
      await db.insert('teams', {
        'name': teams[i],
        'sort_order': i,
        'is_active': 1,
      });
    }

    // 1. Insert Subscription Plans
    await db.insert('plans', {
      'id': 1,
      'name': 'باقة الأساسيات (8 حصص)',
      'sessions_count': 8,
      'price': 600.0,
      'duration_days': 30,
    });

    await db.insert('plans', {
      'id': 2,
      'name': 'باقة التطوير المتقدم (12 حصة)',
      'sessions_count': 12,
      'price': 850.0,
      'duration_days': 30,
    });

    await db.insert('plans', {
      'id': 3,
      'name': 'باقة الاحتراف المكثف (16 حصة)',
      'sessions_count': 16,
      'price': 1200.0,
      'duration_days': 45,
    });

    await db.insert('plans', {
      'id': 4,
      'name': 'باقة البراعم (6 حصص)',
      'sessions_count': 6,
      'price': 450.0,
      'duration_days': 30,
    });

    // 2. Insert Trainees
    // Trainee 1: Has completed all sessions (Alert: Zero Sessions Remaining)
    await db.insert('trainees', {
      'id': 1,
      'name': 'يوسف أحمد محمود',
      'phone': '01012345678',
      'age': 16,
      'group_name': 'الشباب',
      'plan_id': 2,
      'total_sessions': 12,
      'attended_sessions': 12,
      'total_fee': 850.0,
      'paid_amount': 850.0,
      'status': 'Active',
      'join_date': '2026-07-01',
    });

    // Trainee 2: Has unpaid debt (Alert: 300 EGP Pending)
    await db.insert('trainees', {
      'id': 2,
      'name': 'عمر طارق حسن',
      'phone': '01198765432',
      'age': 13,
      'group_name': 'الناشئون أ',
      'plan_id': 1,
      'total_sessions': 8,
      'attended_sessions': 4,
      'total_fee': 600.0,
      'paid_amount': 300.0,
      'status': 'Active',
      'join_date': '2026-07-15',
    });

    // Trainee 3: Active & Fully Paid
    await db.insert('trainees', {
      'id': 3,
      'name': 'زياد إبراهيم مصطفى',
      'phone': '01234567890',
      'age': 18,
      'group_name': 'الفريق الأول',
      'plan_id': 3,
      'total_sessions': 16,
      'attended_sessions': 7,
      'total_fee': 1200.0,
      'paid_amount': 1200.0,
      'status': 'Active',
      'join_date': '2026-06-20',
    });

    // Trainee 4: Both Debt & Zero Sessions (Alert in both)
    await db.insert('trainees', {
      'id': 4,
      'name': 'حمزة كريم الشريف',
      'phone': '01511223344',
      'age': 14,
      'group_name': 'الناشئون ب',
      'plan_id': 1,
      'total_sessions': 8,
      'attended_sessions': 8,
      'total_fee': 600.0,
      'paid_amount': 400.0,
      'status': 'Active',
      'join_date': '2026-07-10',
    });

    // Trainee 5: Young cub
    await db.insert('trainees', {
      'id': 5,
      'name': 'مالك حسام الدين',
      'phone': '01088776655',
      'age': 9,
      'group_name': 'البراعم',
      'plan_id': 4,
      'total_sessions': 6,
      'attended_sessions': 2,
      'total_fee': 450.0,
      'paid_amount': 450.0,
      'status': 'Active',
      'join_date': '2026-08-01',
    });

    // Trainee 6: Active
    await db.insert('trainees', {
      'id': 6,
      'name': 'ياسين عمرو عبد الرحمن',
      'phone': '01122334455',
      'age': 12,
      'group_name': 'الناشئون أ',
      'plan_id': 2,
      'total_sessions': 12,
      'attended_sessions': 5,
      'total_fee': 850.0,
      'paid_amount': 850.0,
      'status': 'Active',
      'join_date': '2026-07-25',
    });

    // Trainee 7: Youth with partial payment
    await db.insert('trainees', {
      'id': 7,
      'name': 'فارس محمد سعيد',
      'phone': '01288990011',
      'age': 17,
      'group_name': 'الشباب',
      'plan_id': 2,
      'total_sessions': 12,
      'attended_sessions': 3,
      'total_fee': 850.0,
      'paid_amount': 500.0,
      'status': 'Active',
      'join_date': '2026-08-05',
    });

    // Trainee 8: Juniors B
    await db.insert('trainees', {
      'id': 8,
      'name': 'أدهم علي خليل',
      'phone': '01099887711',
      'age': 15,
      'group_name': 'الناشئون ب',
      'plan_id': 1,
      'total_sessions': 8,
      'attended_sessions': 3,
      'total_fee': 600.0,
      'paid_amount': 600.0,
      'status': 'Active',
      'join_date': '2026-08-02',
    });

    // 3. Insert Attendance Records
    // Today's attendance for Juniors A (Trainee 2, 6)
    await db.insert('attendance', {
      'trainee_id': 2,
      'date': today,
      'status': 'Present',
    });
    await db.insert('attendance', {
      'trainee_id': 6,
      'date': today,
      'status': 'Present',
    });

    // Yesterday's attendance for Youth (Trainee 1, 7)
    await db.insert('attendance', {
      'trainee_id': 1,
      'date': yesterday,
      'status': 'Present',
    });
    await db.insert('attendance', {
      'trainee_id': 7,
      'date': yesterday,
      'status': 'Absent',
    });

    // Two days ago for Juniors B (Trainee 4, 8)
    await db.insert('attendance', {
      'trainee_id': 4,
      'date': twoDaysAgo,
      'status': 'Present',
    });
    await db.insert('attendance', {
      'trainee_id': 8,
      'date': twoDaysAgo,
      'status': 'Excused',
    });

    // 4. Insert Payments Records
    await db.insert('payments', {
      'trainee_id': 1,
      'amount': 850.0,
      'date': '2026-07-01',
      'payment_method': 'InstaPay',
      'notes': 'دفع كامل الاشتراك عبر إنستاباي',
    });

    await db.insert('payments', {
      'trainee_id': 2,
      'amount': 300.0,
      'date': '2026-07-15',
      'payment_method': 'Cash',
      'notes': 'دفعة أولى كاش، المتبقي 300 ج.م',
    });

    await db.insert('payments', {
      'trainee_id': 3,
      'amount': 1200.0,
      'date': '2026-06-20',
      'payment_method': 'Vodafone Cash',
      'notes': 'تحويل فودافون كاش كود 88921',
    });

    await db.insert('payments', {
      'trainee_id': 4,
      'amount': 400.0,
      'date': '2026-07-10',
      'payment_method': 'Cash',
      'notes': 'دفعة جزئية',
    });

    await db.insert('payments', {
      'trainee_id': 5,
      'amount': 450.0,
      'date': '2026-08-01',
      'payment_method': 'Card',
      'notes': 'دفع بالفيزا في مقر الأكاديمية',
    });

    await db.insert('payments', {
      'trainee_id': 6,
      'amount': 850.0,
      'date': '2026-07-25',
      'payment_method': 'InstaPay',
      'notes': 'سداد كامل',
    });

    await db.insert('payments', {
      'trainee_id': 7,
      'amount': 500.0,
      'date': '2026-08-05',
      'payment_method': 'Vodafone Cash',
      'notes': 'دفعة أولى 500 ج.م والمتبقي 350',
    });

    await db.insert('payments', {
      'trainee_id': 8,
      'amount': 600.0,
      'date': '2026-08-02',
      'payment_method': 'Cash',
      'notes': 'سداد نقدي كامل',
    });
  }
}
