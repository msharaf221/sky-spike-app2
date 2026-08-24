import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/payment_model.dart';
import '../models/trainee_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/trainee_repository.dart';

/// State management for Trainees list, filters, search, profile, and CRUD
class TraineeProvider extends ChangeNotifier {
  final TraineeRepository _traineeRepo = TraineeRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TraineeModel> _trainees = [];
  List<TraineeModel> get trainees => _trainees;

  List<String> _groups = ['الكل'];
  List<String> get groups => _groups;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedGroup = 'الكل';
  String get selectedGroup => _selectedGroup;

  String _selectedStatus = 'الكل';
  String get selectedStatus => _selectedStatus;

  String _selectedPaymentStatus = 'الكل';
  String get selectedPaymentStatus => _selectedPaymentStatus;

  // Trainee Detail View State
  TraineeModel? _selectedTrainee;
  TraineeModel? get selectedTrainee => _selectedTrainee;

  List<AttendanceModel> _traineeAttendanceHistory = [];
  List<AttendanceModel> get traineeAttendanceHistory => _traineeAttendanceHistory;

  List<PaymentModel> _traineePaymentHistory = [];
  List<PaymentModel> get traineePaymentHistory => _traineePaymentHistory;

  Future<void> loadTrainees() async {
    _isLoading = true;
    notifyListeners();

    try {
      final distinctGroups = await _traineeRepo.getDistinctGroups();
      _groups = ['الكل', ...distinctGroups];

      _trainees = await _traineeRepo.getAllTrainees(
        searchQuery: _searchQuery,
        groupFilter: _selectedGroup,
        statusFilter: _selectedStatus,
        paymentFilter: _selectedPaymentStatus,
      );
    } catch (e) {
      debugPrint('Error loading trainees: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTrainees();
  }

  void setFilterGroup(String group) {
    _selectedGroup = group;
    loadTrainees();
  }

  void setFilterStatus(String status) {
    _selectedStatus = status;
    loadTrainees();
  }

  void setFilterPayment(String paymentStatus) {
    _selectedPaymentStatus = paymentStatus;
    loadTrainees();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedGroup = 'الكل';
    _selectedStatus = 'الكل';
    _selectedPaymentStatus = 'الكل';
    loadTrainees();
  }

  Future<bool> addTrainee(
    TraineeModel trainee, {
    double initialPayment = 0.0,
    String paymentMethod = 'Cash',
    String? notes,
  }) async {
    try {
      await _traineeRepo.insertTrainee(
        trainee,
        initialPayment: initialPayment,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      await loadTrainees();
      return true;
    } catch (e) {
      debugPrint('Error adding trainee: $e');
      return false;
    }
  }

  Future<bool> updateTrainee(TraineeModel trainee) async {
    try {
      await _traineeRepo.updateTrainee(trainee);
      if (_selectedTrainee?.id == trainee.id) {
        _selectedTrainee = await _traineeRepo.getTraineeById(trainee.id!);
      }
      await loadTrainees();
      return true;
    } catch (e) {
      debugPrint('Error updating trainee: $e');
      return false;
    }
  }

  Future<bool> deleteTrainee(int id) async {
    try {
      await _traineeRepo.deleteTrainee(id);
      await loadTrainees();
      return true;
    } catch (e) {
      debugPrint('Error deleting trainee: $e');
      return false;
    }
  }

  Future<void> loadTraineeDetails(int traineeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedTrainee = await _traineeRepo.getTraineeById(traineeId);
      _traineeAttendanceHistory = await _attendanceRepo.getTraineeAttendanceHistory(traineeId);
      _traineePaymentHistory = await _paymentRepo.getPaymentsByTrainee(traineeId);
    } catch (e) {
      debugPrint('Error loading trainee details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> renewSubscription({
    required int traineeId,
    required int planId,
    required double planPrice,
    required int sessionsCount,
    required double paidAmount,
    required String paymentMethod,
    required String date,
    String? notes,
  }) async {
    try {
      await _traineeRepo.renewSubscription(
        traineeId: traineeId,
        planId: planId,
        planPrice: planPrice,
        sessionsCount: sessionsCount,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        date: date,
        notes: notes,
      );
      await loadTraineeDetails(traineeId);
      await loadTrainees();
      return true;
    } catch (e) {
      debugPrint('Error renewing subscription: $e');
      return false;
    }
  }
}
