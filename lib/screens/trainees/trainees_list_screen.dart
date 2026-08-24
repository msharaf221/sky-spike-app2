import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/dialog_helper.dart';
import '../../providers/trainee_provider.dart';
import '../finance/record_payment_dialog.dart';
import 'trainee_detail_screen.dart';
import 'trainee_form_screen.dart';
import 'widgets/trainee_card.dart';
import 'widgets/trainee_filter_bottom_sheet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class TraineesListScreen extends StatefulWidget {
  const TraineesListScreen({super.key});

  @override
  State<TraineesListScreen> createState() => _TraineesListScreenState();
}

class _TraineesListScreenState extends State<TraineesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineeProvider>().loadTrainees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TraineeFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.traineesTitle,
        subtitle: 'إدارة المتدربين والاشتراكات',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'تصفية',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('متدرب جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TraineeFormScreen()),
          );
          if (added == true && mounted) {
            context.read<TraineeProvider>().loadTrainees();
          }
        },
      ),
      body: Consumer<TraineeProvider>(
        builder: (context, provider, child) {
          final hasActiveFilters = provider.selectedGroup != 'الكل' ||
              provider.selectedStatus != 'الكل' ||
              provider.selectedPaymentStatus != 'الكل';

          return Column(
            children: [
              // Search Bar & Filter Summary Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                color: Colors.white,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => provider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: AppStrings.searchTraineePlaceholder,
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('التصفيات: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            if (provider.selectedGroup != 'الكل')
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Chip(
                                  label: Text(provider.selectedGroup, style: const TextStyle(fontSize: 11)),
                                  onDeleted: () => provider.setFilterGroup('الكل'),
                                  deleteIconColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            if (provider.selectedStatus != 'الكل')
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Chip(
                                  label: Text(provider.selectedStatus, style: const TextStyle(fontSize: 11)),
                                  onDeleted: () => provider.setFilterStatus('الكل'),
                                  deleteIconColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            if (provider.selectedPaymentStatus != 'الكل')
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Chip(
                                  label: Text(provider.selectedPaymentStatus, style: const TextStyle(fontSize: 11)),
                                  onDeleted: () => provider.setFilterPayment('الكل'),
                                  deleteIconColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trainees List View
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.trainees.isEmpty
                        ? EmptyStateView(
                            title: 'لا يوجد متدربون مطابقون للبحث',
                            subtitle: 'يمكنك تعديل خيارات البحث أو إضافة متدرب جديد الآن.',
                            icon: Icons.person_off_outlined,
                            buttonText: 'إضافة متدرب',
                            onButtonPressed: () async {
                              final added = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(builder: (_) => const TraineeFormScreen()),
                              );
                              if (added == true && mounted) {
                                provider.loadTrainees();
                              }
                            },
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async => provider.loadTrainees(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                              itemCount: provider.trainees.length,
                              itemBuilder: (context, index) {
                                final trainee = provider.trainees[index];
                                return TraineeCard(
                                  trainee: trainee,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TraineeDetailScreen(traineeId: trainee.id!),
                                      ),
                                    ).then((_) => provider.loadTrainees());
                                  },
                                  onEdit: () async {
                                    final updated = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TraineeFormScreen(traineeToEdit: trainee),
                                      ),
                                    );
                                    if (updated == true && mounted) {
                                      provider.loadTrainees();
                                    }
                                  },
                                  onDelete: () async {
                                    final confirmed = await DialogHelper.showConfirmDialog(
                                      context,
                                      title: AppStrings.deleteTrainee,
                                      message: AppStrings.confirmDeleteTrainee,
                                      isDestructive: true,
                                    );
                                    if (confirmed && mounted) {
                                      final success = await provider.deleteTrainee(trainee.id!);
                                      if (success && mounted) {
                                        DialogHelper.showSnackBar(
                                          context,
                                          message: AppStrings.successDeleted,
                                          isSuccess: true,
                                        );
                                      }
                                    }
                                  },
                                  onRecordPayment: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => RecordPaymentDialog(
                                        preselectedTraineeId: trainee.id,
                                        suggestedAmount: trainee.remainingDebt,
                                        onPaymentSaved: () => provider.loadTrainees(),
                                      ),
                                    );
                                  },
                                  onRenew: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TraineeDetailScreen(traineeId: trainee.id!),
                                      ),
                                    ).then((_) => provider.loadTrainees());
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
