import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/plan_model.dart';
import '../../providers/plan_provider.dart';
import 'plan_form_dialog.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

/// Screen to view, create, edit, and delete subscription plans
class PlansManagementScreen extends StatefulWidget {
  const PlansManagementScreen({super.key});

  @override
  State<PlansManagementScreen> createState() => _PlansManagementScreenState();
}

class _PlansManagementScreenState extends State<PlansManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  void _openPlanDialog([PlanModel? plan]) {
    showDialog(
      context: context,
      builder: (_) => PlanFormDialog(planToEdit: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'إدارة باقات الاشتراك',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_card),
        label: const Text('باقة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openPlanDialog(),
      ),
      body: Consumer<PlanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.plans.isEmpty) {
            return EmptyStateView(
              title: 'لا توجد باقات اشتراك مضافة',
              subtitle: 'أضف باقات الاشتراكات لتسهيل تسجيل المتدربين ومتابعة الحصص.',
              icon: Icons.card_membership_outlined,
              buttonText: 'إضافة باقة',
              onButtonPressed: () => _openPlanDialog(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.plans.length,
            itemBuilder: (context, index) {
              final plan = provider.plans[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.sports_volleyball, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${plan.sessionsCount} حصص تدريبية',
                                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• مدة ${plan.durationDays} يوم',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${plan.price.toStringAsFixed(0)} ج.م',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _openPlanDialog(plan),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                final confirm = await DialogHelper.showConfirmDialog(
                                  context,
                                  title: AppStrings.deletePlan,
                                  message: 'هل أنت متأكد من رغبتك في حذف باقة "${plan.name}"؟',
                                  isDestructive: true,
                                );
                                if (confirm && mounted) {
                                  final error = await provider.deletePlan(plan.id!);
                                  if (error != null && mounted) {
                                    DialogHelper.showSnackBar(context, message: error, isError: true);
                                  } else if (mounted) {
                                    DialogHelper.showSnackBar(
                                      context,
                                      message: AppStrings.successDeleted,
                                      isSuccess: true,
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
