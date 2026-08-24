import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/plan_model.dart';
import '../../models/trainee_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/trainee_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

class TraineeFormScreen extends StatefulWidget {
  final TraineeModel? traineeToEdit;

  const TraineeFormScreen({super.key, this.traineeToEdit});

  @override
  State<TraineeFormScreen> createState() => _TraineeFormScreenState();
}

class _TraineeFormScreenState extends State<TraineeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _customGroupController;
  late TextEditingController _totalFeeController;
  late TextEditingController _paidAmountController;
  late TextEditingController _notesController;

  String _selectedGroup = 'ناشئين أ';
  bool _isCustomGroup = false;
  PlanModel? _selectedPlan;
  String _status = 'Active';
  DateTime _joinDate = DateTime.now();
  String _paymentMethod = 'Cash';
  bool _isSubmitting = false;

  final List<String> _predefinedGroups = [
    'ناشئين أ',
    'ناشئين ب',
    'فريق الشباب',
    'الفريق الأول',
    'أكاديمية البراعم',
    'أخرى (مجموعة مخصصة)'
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.traineeToEdit;

    _nameController = TextEditingController(text: t?.name ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _ageController = TextEditingController(text: t?.age.toString() ?? '');
    _customGroupController = TextEditingController();
    _totalFeeController = TextEditingController(text: t?.totalFee.toStringAsFixed(0) ?? '');
    _paidAmountController = TextEditingController(text: t?.paidAmount.toStringAsFixed(0) ?? '0');
    _notesController = TextEditingController();

    if (t != null) {
      if (_predefinedGroups.contains(t.groupName)) {
        _selectedGroup = t.groupName;
      } else {
        _selectedGroup = 'أخرى (مجموعة مخصصة)';
        _isCustomGroup = true;
        _customGroupController.text = t.groupName;
      }
      _status = t.status;
      try {
        _joinDate = DateTime.parse(t.joinDate);
      } catch (_) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans().then((_) {
        final plans = context.read<PlanProvider>().plans;
        if (plans.isNotEmpty && mounted) {
          setState(() {
            if (t != null) {
              _selectedPlan = plans.firstWhere(
                (p) => p.id == t.planId,
                orElse: () => plans.first,
              );
            } else {
              _selectedPlan = plans.first;
              _totalFeeController.text = _selectedPlan!.price.toStringAsFixed(0);
              _paidAmountController.text = _selectedPlan!.price.toStringAsFixed(0);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _customGroupController.dispose();
    _totalFeeController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPlanChanged(PlanModel? plan) {
    if (plan != null) {
      setState(() {
        _selectedPlan = plan;
        if (widget.traineeToEdit == null) {
          _totalFeeController.text = plan.price.toStringAsFixed(0);
          _paidAmountController.text = plan.price.toStringAsFixed(0);
        }
      });
    }
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2020),
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
      setState(() => _joinDate = picked);
    }
  }

  Future<void> _saveTrainee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan == null) {
      DialogHelper.showSnackBar(context, message: 'يرجى اختيار باقة اشتراك', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final group = _isCustomGroup ? _customGroupController.text.trim() : _selectedGroup;
      final totalFee = double.tryParse(_totalFeeController.text.trim()) ?? _selectedPlan!.price;
      final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;
      final joinDateStr = DateFormat('yyyy-MM-dd').format(_joinDate);

      final traineeProvider = context.read<TraineeProvider>();

      if (widget.traineeToEdit == null) {
        // Create new trainee
        final newTrainee = TraineeModel(
          name: name,
          phone: phone,
          age: age,
          groupName: group,
          planId: _selectedPlan!.id!,
          totalSessions: _selectedPlan!.sessionsCount,
          attendedSessions: 0,
          totalFee: totalFee,
          paidAmount: paidAmount,
          status: _status,
          joinDate: joinDateStr,
        );

        final success = await traineeProvider.addTrainee(
          newTrainee,
          initialPayment: paidAmount,
          paymentMethod: _paymentMethod,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

        if (success && mounted) {
          DialogHelper.showSnackBar(context, message: 'تمت إضافة المتدرب بنجاح', isSuccess: true);
          Navigator.pop(context, true);
        }
      } else {
        // Update existing trainee
        final updatedTrainee = widget.traineeToEdit!.copyWith(
          name: name,
          phone: phone,
          age: age,
          groupName: group,
          planId: _selectedPlan!.id!,
          totalFee: totalFee,
          paidAmount: paidAmount,
          status: _status,
          joinDate: joinDateStr,
        );

        final success = await traineeProvider.updateTrainee(updatedTrainee);

        if (success && mounted) {
          DialogHelper.showSnackBar(context, message: 'تم تحديث بيانات المتدرب بنجاح', isSuccess: true);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      DialogHelper.showSnackBar(context, message: 'حدث خطأ أثناء الحفظ', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.traineeToEdit != null;
    final plans = context.watch<PlanProvider>().plans;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: isEdit ? AppStrings.editTrainee : AppStrings.addTrainee,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Personal Info Card
              _buildSectionCard(
                title: 'البيانات الشخصية',
                icon: Icons.person_outline,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: AppStrings.traineeName,
                    hint: 'مثال: يوسف أحمد محمود',
                    prefixIcon: Icons.person,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                      if (val.trim().length < 3) return 'الاسم يجب أن يحتوي على 3 أحرف على الأقل';
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _phoneController,
                    label: AppStrings.phone,
                    hint: 'مثال: 01012345678',
                    prefixIcon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                      if (val.trim().length < 10) return 'يرجى إدخال رقم هاتف صحيح';
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _ageController,
                          label: AppStrings.age,
                          hint: 'مثال: 14',
                          prefixIcon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                            final age = int.tryParse(val.trim());
                            if (age == null || age < 4 || age > 60) return 'عمر غير صالح';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomDropdown<String>(
                          label: AppStrings.groupName,
                          value: _selectedGroup,
                          prefixIcon: Icons.groups_outlined,
                          items: _predefinedGroups.map((g) {
                            return DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGroup = val;
                                _isCustomGroup = val == 'أخرى (مجموعة مخصصة)';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_isCustomGroup)
                    CustomTextField(
                      controller: _customGroupController,
                      label: 'اسم المجموعة المخصصة',
                      hint: 'مثال: فريق تحت 12 سنة ب',
                      prefixIcon: Icons.group_add_outlined,
                      validator: (val) {
                        if (_isCustomGroup && (val == null || val.trim().isEmpty)) {
                          return AppStrings.requiredField;
                        }
                        return null;
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 2: Subscription & Financials
              _buildSectionCard(
                title: 'بيانات الاشتراك والباقة',
                icon: Icons.card_membership_outlined,
                children: [
                  CustomDropdown<PlanModel>(
                    label: AppStrings.subscriptionPlan,
                    value: _selectedPlan,
                    prefixIcon: Icons.sports_volleyball,
                    hint: 'اختر باقة الاشتراك',
                    items: plans.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (${p.sessionsCount} حصة - ${p.price.toInt()} ج.م)',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: _onPlanChanged,
                    validator: (p) => p == null ? 'يرجى اختيار باقة' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _totalFeeController,
                          label: AppStrings.totalFee,
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                            if (double.tryParse(val) == null) return AppStrings.invalidNumber;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _paidAmountController,
                          label: AppStrings.paidAmount,
                          prefixIcon: Icons.payments_outlined,
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
                  if (!isEdit) ...[
                    CustomDropdown<String>(
                      label: AppStrings.paymentMethod,
                      value: _paymentMethod,
                      prefixIcon: Icons.account_balance_wallet_outlined,
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
                    CustomTextField(
                      controller: _notesController,
                      label: 'ملاحظات الدفع الأولى (اختياري)',
                      hint: 'مثال: رقم تحويل أو دفعة مقدمة',
                      prefixIcon: Icons.note_alt_outlined,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Section 3: Status & Dates
              _buildSectionCard(
                title: 'حالة التسجيل والتاريخ',
                icon: Icons.settings_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown<String>(
                          label: AppStrings.status,
                          value: _status,
                          prefixIcon: Icons.toggle_on_outlined,
                          items: const [
                            DropdownMenuItem(value: 'Active', child: Text('نشط (Active)')),
                            DropdownMenuItem(value: 'Suspended', child: Text('موقوف (Suspended)')),
                            DropdownMenuItem(value: 'Expired', child: Text('منتهي (Expired)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.joinDate,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickJoinDate,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.divider, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, color: AppColors.primaryLight, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormatter.toArabicDate(_joinDate),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _saveTrainee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isEdit ? 'تحديث بيانات المتدرب' : 'إتمام تسجيل المتدرب',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}
