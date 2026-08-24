import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_helper.dart';
import '../../providers/attendance_provider.dart';
import 'widgets/attendance_summary_bar.dart';
import 'widgets/attendance_tile.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().initAttendance();
    });
  }

  Future<void> _pickDate(AttendanceProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.attendanceTitle,
        subtitle: 'تسجيل وتحديث الحضور اليومي',
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 1. Date Navigation & Selector Header
              Container(
                color: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      tooltip: 'اليوم التالي',
                      onPressed: provider.nextDay,
                    ),
                    InkWell(
                      onTap: () => _pickDate(provider),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.getFriendlyDate(provider.selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      tooltip: 'اليوم السابق',
                      onPressed: provider.prevDay,
                    ),
                  ],
                ),
              ),

              // 2. Group Selector Strip
              if (provider.groups.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: provider.groups.map((group) {
                        final isSelected = provider.selectedGroup == group;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ChoiceChip(
                            label: Text(group),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                            onSelected: (_) => provider.setGroup(group),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // 3. Attendance Real-Time Summary
              AttendanceSummaryBar(
                totalCount: provider.totalCount,
                presentCount: provider.presentCount,
                absentCount: provider.absentCount,
                excusedCount: provider.excusedCount,
                rate: provider.attendanceRate,
              ),

              // 4. Quick Bulk Actions Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => provider.markAll('Present'),
                      icon: const Icon(Icons.done_all, size: 16, color: AppColors.present),
                      label: const Text(
                        AppStrings.markAllPresent,
                        style: TextStyle(color: AppColors.present, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => provider.markAll('Absent'),
                      icon: const Icon(Icons.close, size: 16, color: AppColors.absent),
                      label: const Text(
                        AppStrings.markAllAbsent,
                        style: TextStyle(color: AppColors.absent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Roll Call List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.rollCallList.isEmpty
                        ? const EmptyStateView(
                            title: AppStrings.noTraineesInGroup,
                            subtitle: 'يرجى اختيار مجموعة أخرى أو تسجيل متدربين جدد.',
                            icon: Icons.groups_outlined,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                            itemCount: provider.rollCallList.length,
                            itemBuilder: (context, index) {
                              final item = provider.rollCallList[index];
                              final currentStatus = provider.tempStatusMap[item.trainee.id];

                              return AttendanceTile(
                                trainee: item.trainee,
                                currentStatus: currentStatus,
                                onStatusChanged: (status) {
                                  if (item.trainee.id != null) {
                                    provider.setStatus(item.trainee.id!, status);
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.rollCallList.isEmpty) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          final success = await provider.saveAttendance();
                          if (success && mounted) {
                            DialogHelper.showSnackBar(
                              context,
                              message: AppStrings.attendanceSavedSuccessfully,
                              isSuccess: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    provider.isSaving ? 'جارٍ الحفظ...' : AppStrings.saveAttendance,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
