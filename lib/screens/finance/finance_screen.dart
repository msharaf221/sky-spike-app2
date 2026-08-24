import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/dialog_helper.dart';
import '../../providers/finance_provider.dart';
import 'plans_management_screen.dart';
import 'record_payment_dialog.dart';
import 'widgets/debt_card.dart';
import 'widgets/payment_history_tile.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadFinanceData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openRecordPaymentSheet([int? traineeId, double? debt]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordPaymentDialog(
        preselectedTraineeId: traineeId,
        suggestedAmount: debt,
        onPaymentSaved: () => context.read<FinanceProvider>().loadFinanceData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.financeTitle,
        subtitle: 'المقبوضات والمديونيات والباقات',
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership_outlined, color: Colors.white),
            tooltip: 'إدارة الباقات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlansManagementScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('تسجيل دفعة', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openRecordPaymentSheet(),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 1. Finance KPI Strip
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiBox(
                        title: 'تحصيل الشهر',
                        value: '${provider.monthlyRevenue.toStringAsFixed(0)} ج.م',
                        color: AppColors.success,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiBox(
                        title: 'الديون المعلقة',
                        value: '${provider.totalDebt.toStringAsFixed(0)} ج.م',
                        color: AppColors.error,
                        icon: Icons.money_off,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text('${AppStrings.tabDebts} (${provider.debtTrainees.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history, size: 16),
                          const SizedBox(width: 6),
                          Text('${AppStrings.tabPaymentsHistory} (${provider.paymentsHistory.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Tab Views Content
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Debts Tab
                          provider.debtTrainees.isEmpty
                              ? const EmptyStateView(
                                  title: 'لا توجد مديونيات معلقة!',
                                  subtitle: 'جميع المتدربين مسددون لاشتراكاتهم بالكامل.',
                                  icon: Icons.check_circle_outline,
                                )
                              : RefreshIndicator(
                                  color: AppColors.primary,
                                  onRefresh: () async => provider.loadFinanceData(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                                    itemCount: provider.debtTrainees.length,
                                    itemBuilder: (context, index) {
                                      final trainee = provider.debtTrainees[index];
                                      return DebtCard(
                                        trainee: trainee,
                                        onCollect: () => _openRecordPaymentSheet(trainee.id, trainee.remainingDebt),
                                      );
                                    },
                                  ),
                                ),

                          // Payments History Tab
                          provider.paymentsHistory.isEmpty
                              ? const EmptyStateView(
                                  title: 'لا توجد دفعات مالية مسجلة',
                                  subtitle: 'سجل عمليات التحصيل لتتبع الإيرادات المالية.',
                                  icon: Icons.payments_outlined,
                                )
                              : RefreshIndicator(
                                  color: AppColors.primary,
                                  onRefresh: () async => provider.loadFinanceData(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                                    itemCount: provider.paymentsHistory.length,
                                    itemBuilder: (context, index) {
                                      final payment = provider.paymentsHistory[index];
                                      return PaymentHistoryTile(
                                        payment: payment,
                                        onDelete: () async {
                                          final confirm = await DialogHelper.showConfirmDialog(
                                            context,
                                            title: 'حذف عملية الدفع',
                                            message: 'هل تريد حذف هذا السجل المالي بقيمة ${payment.amount} ج.م؟',
                                            isDestructive: true,
                                          );
                                          if (confirm && mounted) {
                                            await provider.deletePayment(payment.id!);
                                            if (mounted) {
                                              DialogHelper.showSnackBar(
                                                context,
                                                message: 'تم حذف الدفعة بنجاح',
                                                isSuccess: true,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
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
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
