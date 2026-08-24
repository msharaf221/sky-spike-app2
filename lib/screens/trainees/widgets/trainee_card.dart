import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trainee_model.dart';
import '../../../widgets/badge_tag.dart';

/// Interactive Trainee List Card showing progress, debt, and quick actions
class TraineeCard extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRecordPayment;
  final VoidCallback onRenew;

  const TraineeCard({
    super.key,
    required this.trainee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRecordPayment,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final progress = trainee.attendanceProgress;
    final progressColor = trainee.remainingSessions == 0
        ? AppColors.error
        : (trainee.remainingSessions <= 2 ? AppColors.warning : AppColors.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: trainee.hasZeroSessions || trainee.remainingDebt > 0
              ? (trainee.hasZeroSessions ? AppColors.warning.withOpacity(0.5) : AppColors.error.withOpacity(0.3))
              : AppColors.divider.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Avatar + Name + Group + More Menu
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        trainee.name.trim().isNotEmpty ? trainee.name.trim()[0] : '🏐',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainee.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  trainee.groupName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${trainee.age} سنة',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BadgeTag.status(trainee.status),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                      onSelected: (val) {
                        if (val == 'edit') onEdit();
                        if (val == 'delete') onDelete();
                        if (val == 'pay') onRecordPayment();
                        if (val == 'renew') onRenew();
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'pay',
                          child: Row(
                            children: [
                              Icon(Icons.payment, size: 18, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('تسجيل دفعة مالية'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'renew',
                          child: Row(
                            children: [
                              Icon(Icons.autorenew, size: 18, color: AppColors.secondary),
                              SizedBox(width: 8),
                              Text('تجديد الاشتراك'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('تعديل البيانات'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('حذف المتدرب', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 18),

                // 2. Attendance Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الحصص: ${trainee.attendedSessions} من ${trainee.totalSessions} (${(progress * 100).toInt()}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        BadgeTag.sessions(trainee.remainingSessions),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 3. Footer: Plan & Financial Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.card_membership_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          trainee.planName ?? 'باقة الاشتراك',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    BadgeTag.debt(trainee.remainingDebt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
