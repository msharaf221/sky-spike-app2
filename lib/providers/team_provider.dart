import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../repositories/team_repository.dart';

/// State for in-app team / group management.
class TeamProvider extends ChangeNotifier {
  final TeamRepository _repo = TeamRepository();

  List<TeamModel> _teams = [];
  List<TeamModel> get teams => _teams;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TeamModel> get activeTeams =>
      _teams.where((t) => t.isActive).toList(growable: false);

  List<String> get activeNames =>
      activeTeams.map((t) => t.name).toList(growable: false);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _teams = await _repo.getAllTeams();
    } catch (e) {
      debugPrint('Error loading teams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addTeam(String name) async {
    try {
      final nextOrder = _teams.isEmpty
          ? 0
          : _teams.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      await _repo.insertTeam(
        TeamModel(name: name.trim(), sortOrder: nextOrder),
      );
      await load();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> renameTeam(TeamModel team, String newName) async {
    if (team.id == null) return 'فريق غير صالح';
    try {
      await _repo.renameTeam(team.id!, team.name, newName);
      await load();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> setActive(TeamModel team, bool isActive) async {
    if (team.id == null) return 'فريق غير صالح';
    try {
      await _repo.setActive(team.id!, isActive);
      await load();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> deleteTeam(TeamModel team) async {
    try {
      await _repo.deleteTeam(team);
      await load();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = List<TeamModel>.from(_teams);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _teams = list;
    notifyListeners();
    try {
      await _repo.reorder(list);
    } catch (e) {
      debugPrint('Error reordering teams: $e');
      await load();
    }
  }

  Future<int> traineeCount(TeamModel team) => _repo.countTrainees(team.name);
}
