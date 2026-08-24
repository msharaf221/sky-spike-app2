import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trainee_model.dart';

/// Alert Card displaying critical attention items (Zero Sessions or Pending Debt)
class AlertCard extends StatelessWidget {
  final TraineeModel trainee;
  final bool isZeroSessionsAlert;
  final VoidCallback onActionPressed;

  const AlertCard({
    super.key,
    required this.trainee,
    required this.isZeroSessionsAlert,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isZeroSessionsAlert ? AppColors.warningContainer : AppColors.errorContainer;
    final borderColor = isZeroSessionsAlert ? AppColors.warning : AppColors.error;
    final icon = isZeroSessionsAlert ? Icons.timelapse : Icons.warning_amber_rounded;
    final title = isZeroSessionsAlert ? 'استنفذ جميع الحصص' : 'مديونية مستحقة الدفع';
    final actionLabel = isZeroSessionsAlert ? 'تجديد الاشتراك' : 'تحصيل الآن';
    final detailText = isZeroSessionsAlert
        ? 'حضر (${trainee.attendedSessions}/${trainee.totalSessions}) حصة'
        : 'متبقي عليه: ${trainee.remainingDebt.toStringAsFixed(0)} ج.م من إجمالي ${trainee.totalFee.toStringAsFixed(0)} ج.م';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: borderColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trainee.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        trainee.groupName,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  detailText,
                  style: TextStyle(
                    fontSize: 12,
                    color: borderColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onActionPressed,
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
