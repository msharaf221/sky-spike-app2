import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/plan_model.dart';
import '../../models/trainee_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/trainee_provider.dart';
import '../finance/record_payment_dialog.dart';
import 'trainee_form_screen.dart';
import '../../widgets/badge_tag.dart';
import '../../widgets/custom_app_bar.dart';

class TraineeDetailScreen extends StatefulWidget {
  final int traineeId;

  const TraineeDetailScreen({super.key, required this.traineeId});

  @override
  State<TraineeDetailScreen> createState() => _TraineeDetailScreenState();
}

class _TraineeDetailScreenState extends State<TraineeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineeProvider>().loadTraineeDetails(widget.traineeId);
      context.read<PlanProvider>().loadPlans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRenewDialog(TraineeModel trainee) {
    final plans = context.read<PlanProvider>().plans;
    if (plans.isEmpty) {
      DialogHelper.showSnackBar(context, message: 'لا توجد باقات مسجلة، يرجى إضافة باقة أولاً', isError: true);
      return;
    }

    PlanModel selectedPlan = plans.firstWhere(
      (p) => p.id == trainee.planId,
      orElse: () => plans.first,
    );

    final feeController = TextEditingController(text: selectedPlan.price.toStringAsFixed(0));
    final paidController = TextEditingController(text: selectedPlan.price.toStringAsFixed(0));
    String paymentMethod = 'Cash';
    final notesController = TextEditingController(text: 'تجديد اشتراك');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.autorenew, color: AppColors.secondary),
              SizedBox(width: 8),
              Text('تجديد اشتراك المتدرب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المتدرب: ${trainee.name}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                ),
                const SizedBox(height: 14),

                // Plan Dropdown
                const Text('اختر الباقة الجديدة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<PlanModel>(
                  value: selectedPlan,
                  items: plans.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${p.sessionsCount} حصة - ${p.price.toInt()} ج.م)'),
                    );
                  }).toList(),
                  onChanged: (newP) {
                    if (newP != null) {
                      setDialogState(() {
                        selectedPlan = newP;
                        feeController.text = newP.price.toStringAsFixed(0);
                        paidController.text = newP.price.toStringAsFixed(0);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 14),

                // Paid Amount
                const Text('المبلغ المسدد الآن (ج.م):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: paidController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 14),

                // Payment Method
                const Text('طريقة الدفع:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('نقدي (كاش)')),
                    DropdownMenuItem(value: 'InstaPay', child: Text('إنستاباي (InstaPay)')),
                    DropdownMenuItem(value: 'Vodafone Cash', child: Text('فودافون كاش')),
                    DropdownMenuItem(value: 'Card', child: Text('بطاقة بنكية / فيزا')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => paymentMethod = v);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final paid = double.tryParse(paidController.text.trim()) ?? 0.0;
                final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

                Navigator.pop(ctx);
                final success = await context.read<TraineeProvider>().renewSubscription(
                      traineeId: trainee.id!,
                      planId: selectedPlan.id!,
                      planPrice: selectedPlan.price,
                      sessionsCount: selectedPlan.sessionsCount,
                      paidAmount: paid,
                      paymentMethod: paymentMethod,
                      date: todayStr,
                      notes: notesController.text.trim(),
                    );

                if (success && mounted) {
                  DialogHelper.showSnackBar(
                    context,
                    message: 'تم تجديد الاشتراك وإضافة الحصص بنجاح',
                    isSuccess: true,
                  );
                }
              },
              child: const Text('تأكيد التجديد'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.traineeDetails,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<TraineeProvider>(
            builder: (context, provider, _) {
              if (provider.selectedTrainee == null) return const SizedBox();
              final trainee = provider.selectedTrainee!;
              return IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'تعديل البيانات',
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TraineeFormScreen(traineeToEdit: trainee),
                    ),
                  );
                  if (updated == true && mounted) {
                    provider.loadTraineeDetails(trainee.id!);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<TraineeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.selectedTrainee == null) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final trainee = provider.selectedTrainee!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          trainee.name.isNotEmpty ? trainee.name[0] : '🏐',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        trainee.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BadgeTag.status(trainee.status),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trainee.groupName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Contact & Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(Icons.phone_outlined, trainee.phone, 'الهاتف'),
                          _buildInfoItem(Icons.cake_outlined, '${trainee.age} سنة', 'العمر'),
                          _buildInfoItem(
                            Icons.calendar_today_outlined,
                            DateFormatter.formatStringDate(trainee.joinDate),
                            'تاريخ الانضمام',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Metrics & Progress Overview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Sessions Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رصيد الحصص', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                '${trainee.attendedSessions} / ${trainee.totalSessions}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 6),
                              BadgeTag.sessions(trainee.remainingSessions),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Financial Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الموقف المالي', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                '${trainee.paidAmount.toStringAsFixed(0)} / ${trainee.totalFee.toStringAsFixed(0)} ج.م',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              BadgeTag.debt(trainee.remainingDebt),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Quick Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRenewDialog(trainee),
                          icon: const Icon(Icons.autorenew, size: 18),
                          label: const Text('تجديد الاشتراك'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => RecordPaymentDialog(
                                preselectedTraineeId: trainee.id,
                                suggestedAmount: trainee.remainingDebt,
                                onPaymentSaved: () => provider.loadTraineeDetails(trainee.id!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.payments_outlined, size: 18),
                          label: const Text('تسجيل دفعة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Tab Bars: Attendance History vs Payment History
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'سجل الحضور (${provider.traineeAttendanceHistory.length})'),
                      Tab(text: 'سجل المدفوعات (${provider.traineePaymentHistory.length})'),
                    ],
                  ),
                ),

                // Tab Views Content
                Container(
                  color: Colors.white,
                  height: 320,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Attendance History List
                      provider.traineeAttendanceHistory.isEmpty
                          ? Center(
                              child: Text('لا توجد سجلات حضور مسجلة حتى الآن', style: TextStyle(color: AppColors.textMuted)),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.traineeAttendanceHistory.length,
                              separatorBuilder: (_, __) => const Divider(height: 16),
                              itemBuilder: (ctx, idx) {
                                final record = provider.traineeAttendanceHistory[idx];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.event_available, size: 20, color: AppColors.primary),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormatter.formatStringDate(record.date),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    BadgeTag.attendance(record.status),
                                  ],
                                );
                              },
                            ),

                      // Payment History List
                      provider.traineePaymentHistory.isEmpty
                          ? Center(
                              child: Text('لا توجد مدفوعات مسجلة حتى الآن', style: TextStyle(color: AppColors.textMuted)),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.traineePaymentHistory.length,
                              separatorBuilder: (_, __) => const Divider(height: 16),
                              itemBuilder: (ctx, idx) {
                                final payment = provider.traineePaymentHistory[idx];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${payment.amount.toStringAsFixed(0)} ج.م',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.success,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${payment.localizedMethod} • ${DateFormatter.formatStringDate(payment.date)}',
                                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        if (payment.notes != null && payment.notes!.isNotEmpty)
                                          Text(
                                            payment.notes!,
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 22),
                                  ],
                                );
                              },
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
