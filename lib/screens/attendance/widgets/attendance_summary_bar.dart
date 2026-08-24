import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Real-time summary strip for current roll call session
class AttendanceSummaryBar extends StatelessWidget {
  final int totalCount;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final double rate;

  const AttendanceSummaryBar({
    super.key,
    required this.totalCount,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الإجمالي', '$totalCount', AppColors.textPrimary),
          _buildStatItem('حاضر', '$presentCount', AppColors.present),
          _buildStatItem('غائب', '$absentCount', AppColors.absent),
          _buildStatItem('معتذر', '$excusedCount', AppColors.excused),
          _buildStatItem('النسبة', '${rate.toStringAsFixed(0)}%', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
