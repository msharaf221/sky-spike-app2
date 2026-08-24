import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/trainee_model.dart';
import '../../providers/finance_provider.dart';
import '../../providers/trainee_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

/// Modal Sheet to record a new payment transaction
class RecordPaymentDialog extends StatefulWidget {
  final int? preselectedTraineeId;
  final double? suggestedAmount;
  final VoidCallback? onPaymentSaved;

  const RecordPaymentDialog({
    super.key,
    this.preselectedTraineeId,
    this.suggestedAmount,
    this.onPaymentSaved,
  });

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  TraineeModel? _selectedTrainee;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String _paymentMethod = 'Cash';
  DateTime _paymentDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.suggestedAmount != null && widget.suggestedAmount! > 0
          ? widget.suggestedAmount!.toStringAsFixed(0)
          : '',
    );
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineeProvider>().loadTrainees().then((_) {
        final trainees = context.read<TraineeProvider>().trainees;
        if (widget.preselectedTraineeId != null && trainees.isNotEmpty) {
          setState(() {
            _selectedTrainee = trainees.firstWhere(
              (t) => t.id == widget.preselectedTraineeId,
              orElse: () => trainees.first,
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTrainee == null) {
      DialogHelper.showSnackBar(context, message: 'يرجى اختيار المتدرب', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      DialogHelper.showSnackBar(context, message: 'يرجى إدخال مبلغ صحيح', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_paymentDate);
      final success = await context.read<FinanceProvider>().recordPayment(
            traineeId: _selectedTrainee!.id!,
            amount: amount,
            date: dateStr,
            paymentMethod: _paymentMethod,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          );

      if (success && mounted) {
        DialogHelper.showSnackBar(
          context,
          message: 'تم تسجيل الدفعة المالية بنجاح',
          isSuccess: true,
        );
        widget.onPaymentSaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      DialogHelper.showSnackBar(context, message: 'حدث خطأ أثناء حفظ الدفعة', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainees = context.watch<TraineeProvider>().trainees;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: AppColors.success),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.recordPayment,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Trainee Selector (if not fixed)
              if (widget.preselectedTraineeId != null && _selectedTrainee != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTrainee!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'المجموعة: ${_selectedTrainee!.groupName}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        'المتبقي: ${_selectedTrainee!.remainingDebt.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                CustomDropdown<TraineeModel>(
                  label: 'اختر المتدرب',
                  value: _selectedTrainee,
                  prefixIcon: Icons.person_search,
                  hint: 'اختر اللاعب المسدد للدفعة',
                  items: trainees.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        '${t.name} (${t.groupName}) - متبقي: ${t.remainingDebt.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (t) {
                    if (t != null) {
                      setState(() {
                        _selectedTrainee = t;
                        if (t.remainingDebt > 0) {
                          _amountController.text = t.remainingDebt.toStringAsFixed(0);
                        }
                      });
                    }
                  },
                  validator: (t) => t == null ? 'يرجى اختيار متدرب' : null,
                ),
              ],

              // Amount Field
              CustomTextField(
                controller: _amountController,
                label: AppStrings.paymentAmount,
                hint: 'أدخل المبلغ بالجنيه المصري',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                  if (double.tryParse(val) == null) return AppStrings.invalidNumber;
                  return null;
                },
              ),

              // Payment Method
              CustomDropdown<String>(
                label: AppStrings.paymentMethod,
                value: _paymentMethod,
                prefixIcon: Icons.payment,
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('نقدي (كاش)')),
                  DropdownMenuItem(value: 'InstaPay', child: Text('إنستاباي (InstaPay)')),
                  DropdownMenuItem(value: 'Vodafone Cash', child: Text('فودافون كاش')),
                  DropdownMenuItem(value: 'Card', child: Text('بطاقة بنكية / فيزا')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),

              // Date Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.paymentDate,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primaryLight, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.toArabicDate(_paymentDate),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notes
              CustomTextField(
                controller: _notesController,
                label: AppStrings.paymentNotes,
                hint: 'رقم التحويل أو تفاصيل إضافية (اختياري)',
                prefixIcon: Icons.note_alt_outlined,
              ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSaving ? 'جارٍ الحفظ...' : 'تأكيد وحفظ الدفعة',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
