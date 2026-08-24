import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/plan_model.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/custom_text_field.dart';

/// Modal dialog to create or edit a Subscription Plan
class PlanFormDialog extends StatefulWidget {
  final PlanModel? planToEdit;

  const PlanFormDialog({super.key, this.planToEdit});

  @override
  State<PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _sessionsController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.planToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _sessionsController = TextEditingController(text: p?.sessionsCount.toString() ?? '8');
    _priceController = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '600');
    _durationController = TextEditingController(text: p?.durationDays.toString() ?? '30');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sessionsController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final sessions = int.parse(_sessionsController.text.trim());
      final price = double.parse(_priceController.text.trim());
      final duration = int.parse(_durationController.text.trim());

      final provider = context.read<PlanProvider>();

      if (widget.planToEdit == null) {
        final newPlan = PlanModel(
          name: name,
          sessionsCount: sessions,
          price: price,
          durationDays: duration,
        );
        final success = await provider.addPlan(newPlan);
        if (success && mounted) {
          DialogHelper.showSnackBar(context, message: 'تمت إضافة الباقة بنجاح', isSuccess: true);
          Navigator.pop(context, true);
        }
      } else {
        final updatedPlan = widget.planToEdit!.copyWith(
          name: name,
          sessionsCount: sessions,
          price: price,
          durationDays: duration,
        );
        final success = await provider.updatePlan(updatedPlan);
        if (success && mounted) {
          DialogHelper.showSnackBar(context, message: 'تم تحديث الباقة بنجاح', isSuccess: true);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      DialogHelper.showSnackBar(context, message: 'حدث خطأ أثناء حفظ الباقة', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.planToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add_card, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            isEdit ? AppStrings.editPlan : AppStrings.addPlan,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: AppStrings.planName,
                hint: 'مثال: باقة 12 حصة شهرياً',
                prefixIcon: Icons.title,
                validator: (val) => val == null || val.trim().isEmpty ? AppStrings.requiredField : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _sessionsController,
                      label: AppStrings.planSessions,
                      hint: 'مثال: 12',
                      prefixIcon: Icons.sports_volleyball,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                        if (int.tryParse(val) == null) return AppStrings.invalidNumber;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: AppStrings.planPrice,
                      hint: 'مثال: 850',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                        if (double.tryParse(val) == null) return AppStrings.invalidNumber;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _durationController,
                label: AppStrings.planDuration,
                hint: 'مثال: 30',
                prefixIcon: Icons.date_range,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                  if (int.tryParse(val) == null) return AppStrings.invalidNumber;
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSaving ? null : _save,
          child: Text(isEdit ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}
