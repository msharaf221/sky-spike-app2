import 'package:intl/intl.dart';
import '../core/database/app_database.dart';

class MonthlyAnalytics {
  final String yearMonth;
  final double totalRevenue;
  final double totalDebt;
  final int totalTrainees;
  final int activeTrainees;
  final int totalPresentCount;
  final int totalAbsentCount;
  final int totalExcusedCount;
  final double attendanceRate;
  final Map<String, double> paymentMethodsBreakdown;
  final Map<String, int> groupTraineesCount;

  MonthlyAnalytics({
    required this.yearMonth,
    required this.totalRevenue,
    required this.totalDebt,
    required this.totalTrainees,
    required this.activeTrainees,
    required this.totalPresentCount,
    required this.totalAbsentCount,
    required this.totalExcusedCount,
    required this.attendanceRate,
    required this.paymentMethodsBreakdown,
    required this.groupTraineesCount,
  });
}

/// Repository for Academy Statistics, Reporting & Data Export
class ReportRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<MonthlyAnalytics> getMonthlyAnalytics(String yearMonth) async {
    final db = await _appDb.database;

    // 1. Revenue in this month
    final revRes = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM payments 
      WHERE date LIKE ?
    ''', ['$yearMonth%']);
    final totalRevenue = (revRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // 2. Outstanding debt
    final debtRes = await db.rawQuery('''
      SELECT SUM(total_fee - paid_amount) as total_debt 
      FROM trainees 
      WHERE total_fee > paid_amount AND status = 'Active'
    ''');
    final totalDebt = (debtRes.first['total_debt'] as num?)?.toDouble() ?? 0.0;

    // 3. Trainees counts
    final traineesRes = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) as active_count
      FROM trainees
    ''');
    final totalTrainees = (traineesRes.first['total'] as int?) ?? 0;
    final activeTrainees = (traineesRes.first['active_count'] as int?) ?? 0;

    // 4. Attendance in this month
    final attRes = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_count,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_count,
        SUM(CASE WHEN status = 'Excused' THEN 1 ELSE 0 END) as excused_count
      FROM attendance 
      WHERE date LIKE ?
    ''', ['$yearMonth%']);

    final presentCount = (attRes.first['present_count'] as int?) ?? 0;
    final absentCount = (attRes.first['absent_count'] as int?) ?? 0;
    final excusedCount = (attRes.first['excused_count'] as int?) ?? 0;
    final totalSessionsLogged = presentCount + absentCount + excusedCount;
    final attendanceRate = totalSessionsLogged > 0 ? (presentCount / totalSessionsLogged) * 100 : 0.0;

    // 5. Payment methods breakdown
    final methodsRes = await db.rawQuery('''
      SELECT payment_method, SUM(amount) as total 
      FROM payments 
      WHERE date LIKE ?
      GROUP BY payment_method
    ''', ['$yearMonth%']);

    final Map<String, double> paymentMethods = {};
    for (var row in methodsRes) {
      final method = (row['payment_method'] as String?) ?? 'أخرى';
      final amount = (row['total'] as num?)?.toDouble() ?? 0.0;
      paymentMethods[method] = amount;
    }

    // 6. Group trainee counts
    final groupsRes = await db.rawQuery('''
      SELECT group_name, COUNT(*) as count 
      FROM trainees 
      GROUP BY group_name
      ORDER BY count DESC
    ''');

    final Map<String, int> groupCounts = {};
    for (var row in groupsRes) {
      final group = (row['group_name'] as String?) ?? 'غير محدد';
      final count = (row['count'] as int?) ?? 0;
      groupCounts[group] = count;
    }

    return MonthlyAnalytics(
      yearMonth: yearMonth,
      totalRevenue: totalRevenue,
      totalDebt: totalDebt,
      totalTrainees: totalTrainees,
      activeTrainees: activeTrainees,
      totalPresentCount: presentCount,
      totalAbsentCount: absentCount,
      totalExcusedCount: excusedCount,
      attendanceRate: attendanceRate,
      paymentMethodsBreakdown: paymentMethods,
      groupTraineesCount: groupCounts,
    );
  }

  /// Generate CSV String with UTF-8 BOM for Arabic support in Excel
  Future<String> generateTraineesCsv() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trainees.*, plans.name as plan_name 
      FROM trainees 
      LEFT JOIN plans ON trainees.plan_id = plans.id 
      ORDER BY trainees.id ASC
    ''');

    final StringBuffer buffer = StringBuffer();
    // UTF-8 BOM for Arabic compatibility in Excel
    buffer.write('\uFEFF');
    buffer.writeln('المعرف,الاسم,رقم الهاتف,العمر,المجموعة,الباقة,إجمالي الحصص,الحصص المحضورة,المتبقي,إجمالي الاشتراك,المدفوع,المتبقي,الحالة,تاريخ الانضمام');

    for (final row in maps) {
      final totalSessions = row['total_sessions'] as int? ?? 0;
      final attended = row['attended_sessions'] as int? ?? 0;
      final remaining = (totalSessions - attended).clamp(0, 999);
      final totalFee = (row['total_fee'] as num?)?.toDouble() ?? 0.0;
      final paid = (row['paid_amount'] as num?)?.toDouble() ?? 0.0;
      final debt = (totalFee - paid).clamp(0.0, 999999.0);

      buffer.writeln(
        '${row['id']},'
        '"${row['name']}",'
        '"${row['phone']}",'
        '${row['age']},'
        '"${row['group_name']}",'
        '"${row['plan_name'] ?? ''}",'
        '$totalSessions,'
        '$attended,'
        '$remaining,'
        '$totalFee,'
        '$paid,'
        '$debt,'
        '"${row['status']}",'
        '"${row['join_date']}"',
      );
    }

    return buffer.toString();
  }

  /// Generate Formatted WhatsApp Text Summary
  Future<String> generateWhatsAppSummary(String yearMonth) async {
    final analytics = await getMonthlyAnalytics(yearMonth);
    final formatter = NumberFormat('#,##0.#');

    return '''
🏐 *تقرير أكاديمية سكاي سبايك للكرة الطائرة* 🏐
📅 *شهر:* ${analytics.yearMonth}
----------------------------------------
👥 *إجمالي المشتركين النشطين:* ${analytics.activeTrainees} متدرب
💰 *إجمالي التحصيل الشهري:* ${formatter.format(analytics.totalRevenue)} ج.م
⚠️ *إجمالي المديونيات المعلقة:* ${formatter.format(analytics.totalDebt)} ج.م

📊 *إحصائيات الحضور والغياب:*
✅ الحضور: ${analytics.totalPresentCount} حصة
❌ الغياب: ${analytics.totalAbsentCount} حصة
⚠️ الاعتذار: ${analytics.totalExcusedCount} حصة
📈 نسبة الحضور العام: ${analytics.attendanceRate.toStringAsFixed(1)}%

💳 *تفاصيل التحصيل حسب طريقة الدفع:*
${analytics.paymentMethodsBreakdown.entries.map((e) => '• ${e.key}: ${formatter.format(e.value)} ج.م').join('\n')}

🏢 *توزيع المتدربين على المجموعات:*
${analytics.groupTraineesCount.entries.map((e) => '• ${e.key}: ${e.value} لاعب').join('\n')}
----------------------------------------
_تم استخراج هذا التقرير تلقائياً من تطبيق Sky Spike Management_
''';
  }
}
