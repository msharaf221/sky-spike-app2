import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../repositories/report_repository.dart';

/// Modal sheet for exporting report data as WhatsApp formatted text or CSV
class ExportOptionsSheet extends StatefulWidget {
  final String yearMonth;

  const ExportOptionsSheet({super.key, required this.yearMonth});

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  final ReportRepository _reportRepo = ReportRepository();
  bool _isExporting = false;

  Future<void> _exportAsText() async {
    setState(() => _isExporting = true);
    try {
      final summary = await _reportRepo.generateWhatsAppSummary(widget.yearMonth);
      await Clipboard.setData(ClipboardData(text: summary));

      if (mounted) {
        Navigator.pop(context);
        DialogHelper.showSnackBar(
          context,
          message: 'تم نسخ نص التقرير إلى الحافظة بنجاح، يمكنك لصقه في واتساب الآن.',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showSnackBar(context, message: 'فشل تصدير التقرير', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAsCsv() async {
    setState(() => _isExporting = true);
    try {
      final csvData = await _reportRepo.generateTraineesCsv();
      await Clipboard.setData(ClipboardData(text: csvData));

      if (mounted) {
        Navigator.pop(context);
        DialogHelper.showSnackBar(
          context,
          message: 'تم نسخ جدول البيانات كـ CSV إلى الحافظة لفتحه في Excel.',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showSnackBar(context, message: 'فشل تصدير ملف CSV', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.ios_share, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.exportReport,
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
          const Divider(height: 16),
          Text(
            'اختر طريقة تصدير البيانات ومشاركتها:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // WhatsApp Formatted Text Option
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
            tileColor: AppColors.successContainer.withOpacity(0.3),
            leading: CircleAvatar(
              backgroundColor: Color(0xFF25D366),
              child: Icon(Icons.message, color: Colors.white, size: 20),
            ),
            title: const Text(
              'نسخ تقرير الواتساب المنسق',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'نص مهيأ مع الإيموجي والإحصائيات للإرسال إلى الإدارة وأولياء الأمور',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: _isExporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.copy, color: Color(0xFF25D366)),
            onTap: _isExporting ? null : _exportAsText,
          ),

          const SizedBox(height: 12),

          // CSV Spreadsheet Option
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
            tileColor: AppColors.primaryContainer.withOpacity(0.3),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.table_chart, color: Colors.white, size: 20),
            ),
            title: const Text(
              'نسخ بيانات المتدربين كاملة (CSV / Excel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'جدول بيانات مفصل يدعم اللغة العربية لبرامج Excel و Google Sheets',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: _isExporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.copy, color: AppColors.primary),
            onTap: _isExporting ? null : _exportAsCsv,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
