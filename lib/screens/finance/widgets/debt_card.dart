import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trainee_model.dart';
import '../../../widgets/badge_tag.dart';

/// Card showing unpaid debt details with immediate 'Collect' action
class DebtCard extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onCollect;

  const DebtCard({
    super.key,
    required this.trainee,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.money_off, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainee.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      trainee.groupName,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${trainee.phone}',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'مدفوع: ${trainee.paidAmount.toStringAsFixed(0)} ج.م / الإجمالي: ${trainee.totalFee.toStringAsFixed(0)} ج.م',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BadgeTag.debt(trainee.remainingDebt),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onCollect,
                child: const Text('تحصيل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
