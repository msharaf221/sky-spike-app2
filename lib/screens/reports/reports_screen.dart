import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../repositories/report_repository.dart';
import 'widgets/export_options_sheet.dart';
import '../../widgets/custom_app_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportRepository _reportRepo = ReportRepository();
  DateTime _selectedMonth = DateTime.now();
  MonthlyAnalytics? _analytics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      final data = await _reportRepo.getMonthlyAnalytics(yearMonth);
      setState(() => _analytics = data);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadReport();
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadReport();
  }

  void _showExportSheet() {
    final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportOptionsSheet(yearMonth: yearMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.reportsTitle,
        subtitle: 'تحليلات الأداء والتقارير المالية',
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'تصدير التقرير',
            onPressed: _showExportSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Header
          Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                  onPressed: _nextMonth,
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تقرير شهر: ${DateFormat('MMMM yyyy', 'ar').format(_selectedMonth)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                  onPressed: _prevMonth,
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _analytics == null
                    ? const Center(child: Text('لا توجد بيانات متاحة لهذا الشهر'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Financial KPI Overview
                            _buildSectionHeader('المؤشرات المالية الرئيسية', Icons.account_balance),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'الإيراد المحصل',
                                    value: '${_analytics!.totalRevenue.toStringAsFixed(0)} ج.م',
                                    color: AppColors.success,
                                    icon: Icons.payments,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'الديون المعلقة',
                                    value: '${_analytics!.totalDebt.toStringAsFixed(0)} ج.م',
                                    color: AppColors.error,
                                    icon: Icons.money_off,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 2. Attendance & Participation Performance
                            _buildSectionHeader('أداء الحضور والالتزام', Icons.fact_check),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'نسبة الحضور الإجمالية:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        '${_analytics!.attendanceRate.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _analytics!.attendanceRate / 100,
                                      minHeight: 10,
                                      backgroundColor: AppColors.surfaceVariant,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildAttendanceCountItem(
                                        'حضور',
                                        _analytics!.totalPresentCount,
                                        AppColors.present,
                                        Icons.check_circle,
                                      ),
                                      _buildAttendanceCountItem(
                                        'غياب',
                                        _analytics!.totalAbsentCount,
                                        AppColors.absent,
                                        Icons.cancel,
                                      ),
                                      _buildAttendanceCountItem(
                                        'اعتذار',
                                        _analytics!.totalExcusedCount,
                                        AppColors.excused,
                                        Icons.schedule,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 3. Payment Methods Breakdown
                            _buildSectionHeader(AppStrings.financialBreakdown, Icons.pie_chart),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: _analytics!.paymentMethodsBreakdown.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'لا توجد عمليات تحصيل في هذا الشهر',
                                          style: TextStyle(color: AppColors.textMuted),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _analytics!.paymentMethodsBreakdown.entries.map((e) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.circle, size: 10, color: AppColors.secondary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    e.key,
                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${e.value.toStringAsFixed(0)} ج.م',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),

                            const SizedBox(height: 20),

                            // 4. Trainee Distribution by Group
                            _buildSectionHeader('توزيع المتدربين على المجموعات', Icons.groups),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                children: _analytics!.groupTraineesCount.entries.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          e.key,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${e.value} لاعب',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Export Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _showExportSheet,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.ios_share),
                                label: const Text(
                                  'تصدير ومشاركة التقرير',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCountItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
