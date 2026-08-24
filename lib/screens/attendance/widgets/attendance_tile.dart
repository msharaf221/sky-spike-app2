import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/trainee_model.dart';
import '../../../widgets/badge_tag.dart';

/// Single Trainee Row in Daily Roll Call with 3-state Attendance Buttons
class AttendanceTile extends StatelessWidget {
  final TraineeModel trainee;
  final String? currentStatus; // 'Present', 'Absent', 'Excused', or null
  final Function(String status) onStatusChanged;

  const AttendanceTile({
    super.key,
    required this.trainee,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: currentStatus == 'Present'
              ? AppColors.present.withOpacity(0.4)
              : (currentStatus == 'Absent'
                  ? AppColors.absent.withOpacity(0.4)
                  : (currentStatus == 'Excused'
                      ? AppColors.excused.withOpacity(0.4)
                      : AppColors.divider.withOpacity(0.8))),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Info Row: Name & Remaining Sessions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        trainee.name.isNotEmpty ? trainee.name[0] : '🏐',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'حضر (${trainee.attendedSessions}/${trainee.totalSessions}) حصة',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              BadgeTag.sessions(trainee.remainingSessions),
            ],
          ),

          const SizedBox(height: 10),

          // Segmented 3-Button Attendance Toggle
          Row(
            children: [
              _buildAttendanceButton(
                label: AppStrings.statusPresent,
                statusKey: 'Present',
                activeColor: AppColors.present,
                icon: Icons.check,
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                label: AppStrings.statusAbsent,
                statusKey: 'Absent',
                activeColor: AppColors.absent,
                icon: Icons.close,
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                label: AppStrings.statusExcused,
                statusKey: 'Excused',
                activeColor: AppColors.excused,
                icon: Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton({
    required String label,
    required String statusKey,
    required Color activeColor,
    required IconData icon,
  }) {
    final isSelected = currentStatus == statusKey;

    return Expanded(
      child: Material(
        color: isSelected ? activeColor : AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onStatusChanged(statusKey),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
