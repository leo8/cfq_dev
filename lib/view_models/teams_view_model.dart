import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

class TeamsViewModel extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = true;
// <<<<<<< feature/CFQ-48_phone_authentification
  final String currentUserUid;
// =======
  Map<String, List<model.User>> _teamMembers = {};

// >>>>>>> dev
  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  Map<String, List<model.User>> get teamMembers => _teamMembers;

  TeamsViewModel(this.currentUserUid) {
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('members', arrayContains: currentUserUid)
          .get(const GetOptions(
              source: Source.server)); // Force fetch from server

      _teams = teamsSnapshot.docs.map((doc) => Team.fromSnap(doc)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      await _fetchAllTeamMembers();
    } catch (e) {
      // Handle error
      AppLogger.error('Error fetching teams: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchAllTeamMembers() async {
    for (var team in _teams) {
      _teamMembers[team.uid] = await _fetchTeamMembers(team.members);
    }
  }

  Future<List<model.User>> _fetchTeamMembers(List memberUids) async {
    List<model.User> allMembers = [];
    List<List> chunks = [];

    for (var i = 0; i < memberUids.length; i += 10) {
      chunks.add(memberUids.sublist(
          i, i + 10 > memberUids.length ? memberUids.length : i + 10));
    }

    for (var chunk in chunks) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: chunk)
          .get();

      allMembers.addAll(
          snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList());
    }

    return allMembers;
  }
}
