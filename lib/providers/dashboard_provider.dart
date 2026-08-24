import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trainee_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/trainee_repository.dart';

/// State management for the main Dashboard KPIs and Real-Time Alerts
class DashboardProvider extends ChangeNotifier {
  final TraineeRepository _traineeRepo = TraineeRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _activeTraineesCount = 0;
  int get activeTraineesCount => _activeTraineesCount;

  int _todayPresentCount = 0;
  int get todayPresentCount => _todayPresentCount;

  double _monthlyRevenue = 0.0;
  double get monthlyRevenue => _monthlyRevenue;

  double _outstandingDebt = 0.0;
  double get outstandingDebt => _outstandingDebt;

  List<TraineeModel> _zeroSessionsTrainees = [];
  List<TraineeModel> get zeroSessionsTrainees => _zeroSessionsTrainees;

  List<TraineeModel> _unpaidDebtTrainees = [];
  List<TraineeModel> get unpaidDebtTrainees => _unpaidDebtTrainees;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currentMonthStr = DateFormat('yyyy-MM').format(DateTime.now());

      // 1. Fetch Trainees
      final allTrainees = await _traineeRepo.getAllTrainees();
      _activeTraineesCount = allTrainees.where((t) => t.status == 'Active').length;

      // 2. Fetch Today Attendance
      final attStats = await _attendanceRepo.getAttendanceStatsForDate(todayStr);
      _todayPresentCount = attStats['present'] ?? 0;

      // 3. Fetch Monthly Revenue & Outstanding Debt
      _monthlyRevenue = await _paymentRepo.getMonthlyRevenue(currentMonthStr);
      _outstandingDebt = await _paymentRepo.getTotalOutstandingDebt();

      // 4. Fetch Alerts
      _zeroSessionsTrainees = await _traineeRepo.getZeroSessionsTrainees();
      _unpaidDebtTrainees = await _traineeRepo.getUnpaidDebtTrainees();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
