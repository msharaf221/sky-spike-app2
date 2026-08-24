import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trainee_provider.dart';
import '../attendance/daily_attendance_screen.dart';
import '../finance/plans_management_screen.dart';
import '../finance/record_payment_dialog.dart';
import '../trainees/trainee_detail_screen.dart';
import '../trainees/trainee_form_screen.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/alert_card.dart';
import 'widgets/kpi_card.dart';
import 'widgets/quick_action_button.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  void _refreshAll() {
    context.read<DashboardProvider>().loadDashboardData();
    context.read<TraineeProvider>().loadTrainees();
    context.read<FinanceProvider>().loadFinanceData();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<SettingsProvider>().settings;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: appSettings.clubName,
        subtitle: appSettings.tagline,
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث البيانات',
            onPressed: _refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'الإعدادات',
            onPressed: () => widget.onNavigateTab?.call(5),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final today = DateTime.now();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome & Date Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormatter.getFriendlyDate(today),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مرحباً بك في ${appSettings.clubName} 🏐',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تابع حضور المتدربين والاشتراكات والتحصيل المالي بكل سهولة.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            appSettings.icon,
                            color: AppColors.secondary,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Quick Actions Row
                  const Text(
                    AppStrings.quickActions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      QuickActionButton(
                        label: AppStrings.actionAddTrainee,
                        icon: Icons.person_add_alt_1,
                        color: AppColors.primary,
                        onTap: () async {
                          final added = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const TraineeFormScreen()),
                          );
                          if (added == true) _refreshAll();
                        },
                      ),
                      const SizedBox(width: 8),
                      QuickActionButton(
                        label: AppStrings.actionTakeAttendance,
                        icon: Icons.fact_check_outlined,
                        color: AppColors.secondary,
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(2); // Navigate to Attendance tab
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DailyAttendanceScreen()),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      QuickActionButton(
                        label: AppStrings.actionRecordPayment,
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.success,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RecordPaymentDialog(
                              onPaymentSaved: _refreshAll,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      QuickActionButton(
                        label: AppStrings.actionManagePlans,
                        icon: Icons.card_membership_outlined,
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlansManagementScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. KPI Grid (2x2)
                  const Text(
                    'مؤشرات الأداء الرئيسية (KPIs)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      KpiCard(
                        title: AppStrings.kpiActiveTrainees,
                        value: '${provider.activeTraineesCount} لاعب',
                        icon: Icons.groups_outlined,
                        iconColor: AppColors.primary,
                        iconBackgroundColor: AppColors.primaryContainer,
                        subtitle: 'مشترك نشط حالياً',
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                      KpiCard(
                        title: AppStrings.kpiTodayAttendance,
                        value: '${provider.todayPresentCount} حاضر',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                        iconBackgroundColor: AppColors.successContainer,
                        subtitle: 'تم تسجيلهم اليوم',
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                      KpiCard(
                        title: AppStrings.kpiMonthlyRevenue,
                        value: '${provider.monthlyRevenue.toStringAsFixed(0)} ج.م',
                        icon: Icons.payments_outlined,
                        iconColor: Colors.teal,
                        iconBackgroundColor: const Color(0xFFE0F2F1),
                        subtitle: 'إيراد هذا الشهر',
                        onTap: () => widget.onNavigateTab?.call(3),
                      ),
                      KpiCard(
                        title: AppStrings.kpiOutstandingDebt,
                        value: '${provider.outstandingDebt.toStringAsFixed(0)} ج.م',
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.error,
                        iconBackgroundColor: AppColors.errorContainer,
                        subtitle: 'مستحقات معلقة بالخارج',
                        onTap: () => widget.onNavigateTab?.call(3),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. Alerts & Action-Required Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.alertsSection,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (provider.zeroSessionsTrainees.length + provider.unpaidDebtTrainees.length > 0)
                              ? AppColors.errorContainer
                              : AppColors.successContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${provider.zeroSessionsTrainees.length + provider.unpaidDebtTrainees.length} تنبيه',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: (provider.zeroSessionsTrainees.length + provider.unpaidDebtTrainees.length > 0)
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (provider.zeroSessionsTrainees.isEmpty && provider.unpaidDebtTrainees.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.verified_outlined, color: AppColors.success, size: 36),
                          SizedBox(height: 8),
                          Text(
                            AppStrings.noAlerts,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Zero Sessions Alerts
                    if (provider.zeroSessionsTrainees.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          '⚠️ ${AppStrings.zeroSessionsAlert} (${provider.zeroSessionsTrainees.length}):',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      ...provider.zeroSessionsTrainees.map((t) => AlertCard(
                            trainee: t,
                            isZeroSessionsAlert: true,
                            onActionPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TraineeDetailScreen(traineeId: t.id!),
                                ),
                              ).then((_) => _refreshAll());
                            },
                          )),
                    ],

                    const SizedBox(height: 10),

                    // Unpaid Debts Alerts
                    if (provider.unpaidDebtTrainees.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          '🚨 ${AppStrings.unpaidDebtsAlert} (${provider.unpaidDebtTrainees.length}):',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      ...provider.unpaidDebtTrainees.take(5).map((t) => AlertCard(
                            trainee: t,
                            isZeroSessionsAlert: false,
                            onActionPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => RecordPaymentDialog(
                                  preselectedTraineeId: t.id,
                                  suggestedAmount: t.remainingDebt,
                                  onPaymentSaved: _refreshAll,
                                ),
                              );
                            },
                          )),
                    ],
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
