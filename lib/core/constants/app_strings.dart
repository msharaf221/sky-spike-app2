/// Sky Spike Academy Arabic UI Strings & Constants
class AppStrings {
  // App Title
  static const String appName = 'سكاي سبايك';
  static const String appTagline = 'أكاديمية سكاي سبايك للكرة الطائرة';
  static const String currency = 'ج.م';

  // Navigation Items
  static const String navDashboard = 'الرئيسية';
  static const String navTrainees = 'المتدربون';
  static const String navAttendance = 'التحضير';
  static const String navFinance = 'المالية';
  static const String navReports = 'التقارير';

  // Dashboard Strings
  static const String dashboardTitle = 'لوحة التحكم';
  static const String kpiActiveTrainees = 'المتدربون النشطون';
  static const String kpiTodayAttendance = 'حضور اليوم';
  static const String kpiMonthlyRevenue = 'إيرادات الشهر';
  static const String kpiOutstandingDebt = 'ديون معلقة';
  static const String quickActions = 'إجراءات سريعة';
  static const String alertsSection = 'تنبيهات هامة تحتاج متابعة';
  static const String zeroSessionsAlert = 'متدربون استنفذوا الحصص';
  static const String unpaidDebtsAlert = 'متدربون عليهم مستحقات مالية';
  static const String noAlerts = 'لا توجد تنبيهات عاجلة، العمل يسير بشكل ممتاز!';
  static const String actionAddTrainee = 'متدرب جديد';
  static const String actionTakeAttendance = 'تسجيل الحضور';
  static const String actionRecordPayment = 'تسجيل دفعة';
  static const String actionManagePlans = 'إدارة الباقات';

  // Trainee Management Strings
  static const String traineesTitle = 'إدارة المتدربين';
  static const String searchTraineePlaceholder = 'بحث بالاسم أو رقم الهاتف...';
  static const String filterAll = 'الكل';
  static const String filterActive = 'نشط';
  static const String filterSuspended = 'موقوف';
  static const String filterExpired = 'منتهي';
  static const String filterFullyPaid = 'مسدد بالكامل';
  static const String filterHasDebt = 'عليه مديونية';
  static const String addTrainee = 'إضافة متدرب جديد';
  static const String editTrainee = 'تعديل بيانات المتدرب';
  static const String traineeDetails = 'الملف الشخصي للمتدرب';
  static const String traineeName = 'اسم المتدرب';
  static const String phone = 'رقم الهاتف';
  static const String age = 'العمر';
  static const String groupName = 'المجموعة / الفريق';
  static const String subscriptionPlan = 'باقة الاشتراك';
  static const String totalSessions = 'إجمالي الحصص';
  static const String attendedSessions = 'الحصص المحضورة';
  static const String remainingSessions = 'الحصص المتبقية';
  static const String totalFee = 'قيمة الاشتراك';
  static const String paidAmount = 'المبلغ المدفوع';
  static const String remainingDebt = 'المبلغ المتبقي';
  static const String joinDate = 'تاريخ الانضمام';
  static const String status = 'الحالة';
  static const String sessionsProgress = 'تقدم الحصص';
  static const String renewSubscription = 'تجديد الاشتراك';
  static const String deleteTrainee = 'حذف المتدرب';
  static const String confirmDeleteTrainee = 'هل أنت متأكد من حذف هذا المتدرب؟ سيتم حذف سجل الحضور والمدفوعات المرتبطة به.';

  // Attendance Strings
  static const String attendanceTitle = 'دفتر الحضور اليومي';
  static const String selectDate = 'اختر التاريخ';
  static const String selectGroup = 'اختر المجموعة';
  static const String statusPresent = 'حاضر';
  static const String statusAbsent = 'غائب';
  static const String statusExcused = 'معتذر';
  static const String saveAttendance = 'حفظ وتأكيد الحضور';
  static const String markAllPresent = 'تحضير الكل';
  static const String markAllAbsent = 'تصفير الحضور';
  static const String attendanceSavedSuccessfully = 'تم حفظ سجل الحضور بنجاح';
  static const String noTraineesInGroup = 'لا يوجد متدربون مسجلون في هذه المجموعة';
  static const String attendanceSummary = 'ملخص حضور اليوم';
  static const String totalInGroup = 'إجمالي المجموعة';
  static const String presentCount = 'الحاضرون';
  static const String absentCount = 'الغائبون';
  static const String excusedCount = 'المعتذرون';
  static const String attendanceRate = 'نسبة الحضور';

  // Finance & Subscription Strings
  static const String financeTitle = 'المالية والباقات';
  static const String tabDebts = 'المستحقات والديون';
  static const String tabPaymentsHistory = 'سجل المدفوعات';
  static const String tabPlans = 'باقات الاشتراك';
  static const String recordPayment = 'تسجيل دفعة جديدة';
  static const String paymentAmount = 'المبلغ المحصل';
  static const String paymentMethod = 'طريقة الدفع';
  static const String paymentDate = 'تاريخ الدفع';
  static const String paymentNotes = 'ملاحظات / رقم التحويل';
  static const String methodCash = 'نقدي (كاش)';
  static const String methodInstaPay = 'إنستاباي (InstaPay)';
  static const String methodVodafoneCash = 'فودافون كاش';
  static const String methodCard = 'بطاقة بنكية / فيزا';
  static const String addPlan = 'إضافة باقة جديدة';
  static const String editPlan = 'تعديل الباقة';
  static const String planName = 'اسم الباقة';
  static const String planSessions = 'عدد الحصص';
  static const String planPrice = 'سعر الباقة';
  static const String planDuration = 'مدة الصلاحية (بالأيام)';
  static const String deletePlan = 'حذف الباقة';
  static const String cannotDeletePlanInUse = 'لا يمكن حذف هذه الباقة لأن هناك متدربين مشتركين بها حالياً.';

  // Reports Strings
  static const String reportsTitle = 'التقارير والإحصائيات';
  static const String monthlyOverview = 'نظرة عامة على الشهر';
  static const String financialBreakdown = 'التوزيع المالي لطرق الدفع';
  static const String groupPerformance = 'إحصائيات المجموعات';
  static const String exportReport = 'تصدير التقرير';
  static const String exportCsv = 'تصدير كملف إكسل (CSV)';
  static const String exportText = 'نسخ التقرير كرسالة واتساب';
  static const String copySuccess = 'تم نسخ التقرير إلى الحافظة بنجاح';

  // Common Dialog & Button Strings
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String clear = 'إعادة ضبط';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidNumber = 'يرجى إدخال رقم صحيح';
  static const String successSaved = 'تم الحفظ بنجاح';
  static const String successDeleted = 'تم الحذف بنجاح';
  static const String errorOccurred = 'حدث خطأ أثناء العملية، يرجى المحاولة مرة أخرى';
  static const String noDataAvailable = 'لا توجد بيانات متاحة حالياً';
}
