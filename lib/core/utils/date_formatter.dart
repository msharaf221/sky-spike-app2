import 'package:intl/intl.dart';

/// Date formatting utilities with Arabic support
class DateFormatter {
  /// Format as YYYY-MM-DD for database storage
  static String toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format as localized Arabic date (e.g. 24 أغسطس 2026)
  static String toArabicDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format date string (YYYY-MM-DD) to Arabic display
  static String formatStringDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return toArabicDate(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Get Arabic Day Name
  static String getArabicDayName(DateTime date) {
    const days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    return days[date.weekday - 1];
  }

  /// Friendly date label (e.g. اليوم، أمس، أو التاريخ)
  static String getFriendlyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'اليوم (${getArabicDayName(date)})';
    if (diff == -1) return 'أمس (${getArabicDayName(date)})';
    if (diff == 1) return 'غداً (${getArabicDayName(date)})';
    
    return '${getArabicDayName(date)}، ${toArabicDate(date)}';
  }

  /// Format currency with symbol
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.#');
    return '${formatter.format(amount)} ج.م';
  }
}
