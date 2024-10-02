// teams_view_model.dart

import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamsViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Team> _teams = [];
  List<Team> get teams => _teams;

  TeamsViewModel() {
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      // Simulate data fetching with a delay
      await Future.delayed(const Duration(seconds: 1));

      // No teams available at the moment
      _teams = []; // Empty list indicates no teams

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      _isLoading = false;
      notifyListeners();
    }
  }
}
