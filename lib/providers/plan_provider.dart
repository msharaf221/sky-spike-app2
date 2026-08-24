import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../repositories/plan_repository.dart';

/// State management for Subscription Plans CRUD
class PlanProvider extends ChangeNotifier {
  final PlanRepository _planRepo = PlanRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PlanModel> _plans = [];
  List<PlanModel> get plans => _plans;

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plans = await _planRepo.getAllPlans();
    } catch (e) {
      debugPrint('Error loading plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlan(PlanModel plan) async {
    try {
      await _planRepo.insertPlan(plan);
      await loadPlans();
      return true;
    } catch (e) {
      debugPrint('Error adding plan: $e');
      return false;
    }
  }

  Future<bool> updatePlan(PlanModel plan) async {
    try {
      await _planRepo.updatePlan(plan);
      await loadPlans();
      return true;
    } catch (e) {
      debugPrint('Error updating plan: $e');
      return false;
    }
  }

  Future<String?> deletePlan(int planId) async {
    try {
      await _planRepo.deletePlan(planId);
      await loadPlans();
      return null; // Null means success with no error message
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
