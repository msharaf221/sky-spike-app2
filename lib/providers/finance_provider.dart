import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../models/trainee_model.dart';
import '../repositories/payment_repository.dart';

/// State management for Finance, Payments and Debt collection
class FinanceProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepo = PaymentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _monthlyRevenue = 0.0;
  double get monthlyRevenue => _monthlyRevenue;

  double _totalDebt = 0.0;
  double get totalDebt => _totalDebt;

  double _lifetimeRevenue = 0.0;
  double get lifetimeRevenue => _lifetimeRevenue;

  List<TraineeModel> _debtTrainees = [];
  List<TraineeModel> get debtTrainees => _debtTrainees;

  List<PaymentModel> _paymentsHistory = [];
  List<PaymentModel> get paymentsHistory => _paymentsHistory;

  Future<void> loadFinanceData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentMonthStr = DateFormat('yyyy-MM').format(DateTime.now());

      _monthlyRevenue = await _paymentRepo.getMonthlyRevenue(currentMonthStr);
      _totalDebt = await _paymentRepo.getTotalOutstandingDebt();
      _lifetimeRevenue = await _paymentRepo.getTotalLifetimeRevenue();
      _debtTrainees = await _paymentRepo.getTraineesWithDebt();
      _paymentsHistory = await _paymentRepo.getAllPayments();
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordPayment({
    required int traineeId,
    required double amount,
    required String date,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      await _paymentRepo.recordPayment(
        traineeId: traineeId,
        amount: amount,
        date: date,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      await loadFinanceData();
      return true;
    } catch (e) {
      debugPrint('Error recording payment: $e');
      return false;
    }
  }

  Future<bool> deletePayment(int paymentId) async {
    try {
      await _paymentRepo.deletePayment(paymentId);
      await loadFinanceData();
      return true;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      return false;
    }
  }
}
