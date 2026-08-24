import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/dialog_helper.dart';
import '../../models/settings_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class _ColorOption {
  final String label;
  final int value;
  const _ColorOption(this.label, this.value);
}

/// Settings & customization screen (club / team / group details, colors,
/// logo & icon, branding).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<_ColorOption> _primaryOptions = [
    _ColorOption('أزرق ليلي', 0xFF1A237E),
    _ColorOption('أزرق ملكي', 0xFF1565C0),
    _ColorOption('أزرق سماوي', 0xFF0277BD),
    _ColorOption('تركوازي', 0xFF00796B),
    _ColorOption('أخضر', 0xFF2E7D32),
    _ColorOption('بنفسجي', 0xFF6A1B9A),
    _ColorOption('أحمر نبيتي', 0xFFB71C1C),
    _ColorOption('برتقالي', 0xFFE65100),
    _ColorOption('رمادي داكن', 0xFF37474F),
    _ColorOption('زيتوني', 0xFF33691E),
  ];

  static const List<_ColorOption> _secondaryOptions = [
    _ColorOption('برتقالي', 0xFFFF6F00),
    _ColorOption('ذهبي', 0xFFF9A825),
    _ColorOption('وردي', 0xFFF06292),
    _ColorOption('أحمر', 0xFFD32F2F),
    _ColorOption('تركوازي', 0xFF00897B),
    _ColorOption('أخضر', 0xFF43A047),
    _ColorOption('أزرق', 0xFF1E88E5),
    _ColorOption('بنفسجي', 0xFF8E24AA),
    _ColorOption('بني', 0xFF795548),
    _ColorOption('فيروزي', 0xFF00ACC1),
  ];

  late SettingsModel _draft;
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;

  @override
  void initState() {
    super.initState();
    _draft = context.read<SettingsProvider>().settings;
    _nameController = TextEditingController(text: _draft.clubName);
    _taglineController = TextEditingController(text: _draft.tagline);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _save(SettingsProvider settingsProvider) async {
    final name = _nameController.text.trim();
    final tagline = _taglineController.text.trim();

    final updated = _draft.copyWith(
      clubName: name.isEmpty ? AppStrings.appName : name,
      tagline: tagline.isEmpty ? AppStrings.appTagline : tagline,
    );

    final ok = await settingsProvider.save(updated);
    if (!mounted) return;

    if (ok) {
      setState(() => _draft = updated);
      DialogHelper.showSnackBar(
        context,
        message: 'تم حفظ إعدادات الأكاديمية بنجاح ✨',
        isSuccess: true,
      );
    } else {
      DialogHelper.showSnackBar(
        context,
        message: 'حدث خطأ أثناء حفظ الإعدادات، حاول مرة أخرى',
        isError: true,
      );
    }
  }

  Future<void> _reset(SettingsProvider settingsProvider) async {
    final confirmed = await DialogHelper.showConfirmDialog(
      context,
      title: 'إعادة ضبط الإعدادات',
      message: 'هل تريد استعادة الاسم والألوان وأيقونة الشعار الافتراضية؟',
      confirmText: 'استعادة الافتراضي',
    );
    if (!confirmed || !mounted) return;

    final ok = await settingsProvider.reset();
    if (!mounted) return;

    if (ok) {
      final defaults = SettingsModel.defaults();
      setState(() {
        _draft = defaults;
        _nameController.text = defaults.clubName;
        _taglineController.text = defaults.tagline;
      });
      DialogHelper.showSnackBar(
        context,
        message: 'تمت استعادة الإعدادات الافتراضية',
        isSuccess: true,
      );
    } else {
      DialogHelper.showSnackBar(
        context,
        message: 'حدث خطأ أثناء إعادة الضبط',
        isError: true,
      );
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'الإعدادات والتخصيص',
            subtitle: 'بيانات الأكاديمية، الألوان، اللوجو والأيقونات',
            showLogo: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                tooltip: 'حفظ الإعدادات',
                onPressed: settingsProvider.isSaving
                    ? null
                    : () => _save(settingsProvider),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildPreviewCard(),

              // ==== Club / Group / Team details ====
              _sectionHeader('بيانات الأكاديمية / الفريق', Icons.badge_outlined),
              CustomTextField(
                controller: _nameController,
                label: 'اسم الأكاديمية / المجموعة / الفريق',
                hint: 'مثال: سكاي سبايك',
                prefixIcon: Icons.storefront_outlined,
                onChanged: (_) => setState(() {}),
              ),
              CustomTextField(
                controller: _taglineController,
                label: 'الوصف المختصر (Tagline)',
                hint: 'مثال: أكاديمية تدريب الكرة الطائرة',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
              ),

              // ==== Logo / Icon ====
              _sectionHeader('اللوجو والأيقونة', Icons.emoji_objects_outlined),
              _buildIconPicker(),
              const SizedBox(height: 12),
              _buildToggle(
                title: 'إظهار اللوجو في شريط التطبيق',
                subtitle: 'يظهر في الشريط العلوي لكل الشاشات',
                value: _draft.showLogo,
                onChanged: (value) => setState(() {
                  _draft = _draft.copyWith(showLogo: value);
                }),
              ),

              // ==== Primary Color ====
              _sectionHeader('اللون الأساسي (Primary)', Icons.palette_outlined),
              _buildColorGrid(
                options: _primaryOptions,
                selected: _draft.primaryColor,
                onSelected: (value) => setState(
                  () => _draft = _draft.copyWith(primaryColor: value),
                ),
              ),

              // ==== Secondary / Accent Color ====
              _sectionHeader('اللون الثانوي (Accent)', Icons.color_lens_outlined),
              _buildColorGrid(
                options: _secondaryOptions,
                selected: _draft.secondaryColor,
                onSelected: (value) => setState(
                  () => _draft = _draft.copyWith(secondaryColor: value),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: settingsProvider.isSaving
                      ? null
                      : () => _save(settingsProvider),
                  icon: settingsProvider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    settingsProvider.isSaving ? 'جاري الحفظ...' : 'حفظ الإعدادات',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _reset(settingsProvider),
                icon: const Icon(Icons.restart_alt, size: 20),
                label: const Text('استعادة الإعدادات الافتراضية'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(_draft.primary, Colors.black, 0.25)!,
            _draft.primary,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _draft.primary.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _draft.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _draft.secondary.withOpacity(0.45),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(_draft.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.trim().isEmpty
                      ? AppStrings.appName
                      : _nameController.text.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _taglineController.text.trim().isEmpty
                      ? AppStrings.appTagline
                      : _taglineController.text.trim(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _smallSwatch(_draft.primary),
                    const SizedBox(width: 6),
                    _smallSwatch(_draft.secondary),
                    const SizedBox(width: 6),
                    Icon(_draft.icon, color: colorScheme.onPrimary, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallSwatch(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        activeColor: AppColors.primary,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildIconPicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: SettingsIcons.options.map((option) {
          final selected = _draft.iconCode == option.code;
          return InkWell(
            onTap: () => setState(
              () => _draft = _draft.copyWith(iconCode: option.code),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 74,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryContainer : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    option.icon,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorGrid({
    required List<_ColorOption> options,
    required int selected,
    required ValueChanged<int> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((option) {
          final color = Color(option.value);
          final isSelected = selected == option.value;
          return InkWell(
            onTap: () => onSelected(option.value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : Colors.white.withOpacity(0.4),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
