import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/payment_model.dart';

/// Payment transaction log tile
class PaymentHistoryTile extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onDelete;

  const PaymentHistoryTile({
    super.key,
    required this.payment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.traineeName ?? 'متدرب',
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
                      payment.localizedMethod,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${DateFormatter.formatStringDate(payment.date)}',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.notes!,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.amount.toStringAsFixed(0)} ج.م',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
