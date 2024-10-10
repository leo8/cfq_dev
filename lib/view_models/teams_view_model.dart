import 'package:flutter/foundation.dart';
import '../models/team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class TeamsViewModel extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = true;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;

  TeamsViewModel() {
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    _isLoading = true;
    notifyListeners();

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('members', arrayContains: userId)
          .get(const GetOptions(
              source: Source.server)); // Force fetch from server

      _teams = teamsSnapshot.docs.map((doc) => Team.fromSnap(doc)).toList();
    } catch (e) {
      // Handle error
      AppLogger.error('Error fetching teams: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
