import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/trainee_repository.dart';

/// State management for Daily Attendance Roll Call
class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final TraineeRepository _traineeRepo = TraineeRepository();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String _selectedGroup = '';
  String get selectedGroup => _selectedGroup;

  List<String> _groups = [];
  List<String> get groups => _groups;

  List<RollCallItem> _rollCallList = [];
  List<RollCallItem> get rollCallList => _rollCallList;

  // Local map to track unsaved edits: traineeId -> 'Present'|'Absent'|'Excused'
  Map<int, String> _tempStatusMap = {};
  Map<int, String> get tempStatusMap => _tempStatusMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // Quick summary counts
  int get presentCount => _tempStatusMap.values.where((s) => s == 'Present').length;
  int get absentCount => _tempStatusMap.values.where((s) => s == 'Absent').length;
  int get excusedCount => _tempStatusMap.values.where((s) => s == 'Excused').length;
  int get totalCount => _rollCallList.length;
  double get attendanceRate => totalCount > 0 ? (presentCount / totalCount) * 100 : 0.0;

  Future<void> initAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final distinctGroups = await _traineeRepo.getDistinctGroups();
      _groups = distinctGroups;
      if (_groups.isNotEmpty && _selectedGroup.isEmpty) {
        _selectedGroup = _groups.first;
      }
      await loadRollCall();
    } catch (e) {
      debugPrint('Error initializing attendance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    loadRollCall();
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    loadRollCall();
  }

  void prevDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    loadRollCall();
  }

  void setGroup(String group) {
    _selectedGroup = group;
    loadRollCall();
  }

  Future<void> loadRollCall() async {
    if (_selectedGroup.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _rollCallList = await _attendanceRepo.getRollCallSheet(
        date: dateStr,
        groupName: _selectedGroup,
      );

      _tempStatusMap = {};
      for (var item in _rollCallList) {
        if (item.trainee.id != null && item.currentStatus != null) {
          _tempStatusMap[item.trainee.id!] = item.currentStatus!;
        }
      }
    } catch (e) {
      debugPrint('Error loading roll call: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatus(int traineeId, String status) {
    _tempStatusMap[traineeId] = status;
    notifyListeners();
  }

  void markAll(String status) {
    for (var item in _rollCallList) {
      if (item.trainee.id != null) {
        _tempStatusMap[item.trainee.id!] = status;
      }
    }
    notifyListeners();
  }

  Future<bool> saveAttendance() async {
    _isSaving = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await _attendanceRepo.saveRollCallBatch(
        date: dateStr,
        traineeStatusMap: _tempStatusMap,
      );
      await loadRollCall();
      return true;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
