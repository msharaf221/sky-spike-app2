import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Reusable Badge and Status Chip
class BadgeTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsets padding;

  const BadgeTag({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  factory BadgeTag.status(String status) {
    switch (status) {
      case 'Active':
      case 'نشط':
        return const BadgeTag(
          text: 'نشط',
          backgroundColor: AppColors.successContainer,
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case 'Suspended':
      case 'موقوف':
        return const BadgeTag(
          text: 'موقوف',
          backgroundColor: AppColors.warningContainer,
          textColor: AppColors.warning,
          icon: Icons.pause_circle_outline,
        );
      case 'Expired':
      case 'منتهي':
      default:
        return const BadgeTag(
          text: 'منتهي',
          backgroundColor: AppColors.errorContainer,
          textColor: AppColors.error,
          icon: Icons.cancel_outlined,
        );
    }
  }

  factory BadgeTag.attendance(String status) {
    switch (status) {
      case 'Present':
      case 'حاضر':
        return const BadgeTag(
          text: 'حاضر',
          backgroundColor: AppColors.successContainer,
          textColor: AppColors.success,
          icon: Icons.check,
        );
      case 'Absent':
      case 'غائب':
        return const BadgeTag(
          text: 'غائب',
          backgroundColor: AppColors.errorContainer,
          textColor: AppColors.error,
          icon: Icons.close,
        );
      case 'Excused':
      case 'معتذر':
      default:
        return const BadgeTag(
          text: 'معتذر',
          backgroundColor: AppColors.warningContainer,
          textColor: AppColors.warning,
          icon: Icons.schedule,
        );
    }
  }

  factory BadgeTag.debt(double debtAmount) {
    if (debtAmount <= 0) {
      return const BadgeTag(
        text: 'خالص السداد',
        backgroundColor: AppColors.successContainer,
        textColor: AppColors.success,
        icon: Icons.done_all,
      );
    } else {
      return BadgeTag(
        text: 'متبقي ${debtAmount.toStringAsFixed(0)} ج.م',
        backgroundColor: AppColors.errorContainer,
        textColor: AppColors.error,
        icon: Icons.warning_amber_rounded,
      );
    }
  }

  factory BadgeTag.sessions(int remaining) {
    if (remaining <= 0) {
      return const BadgeTag(
        text: 'استنفذ الحصص (0)',
        backgroundColor: AppColors.errorContainer,
        textColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } else if (remaining <= 2) {
      return BadgeTag(
        text: 'متبقي $remaining حصص',
        backgroundColor: AppColors.warningContainer,
        textColor: AppColors.warning,
        icon: Icons.timelapse,
      );
    } else {
      return BadgeTag(
        text: 'متبقي $remaining حصص',
        backgroundColor: AppColors.primaryContainer,
        textColor: AppColors.primary,
        icon: Icons.sports_volleyball,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
