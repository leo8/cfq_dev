import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';

class TeamDetailsViewModel extends ChangeNotifier {
  Team _team;
  List<model.User> _members = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TeamDetailsViewModel({required Team team}) : _team = team {
    _fetchTeamMembers();
  }

  Team get team => _team;
  List<model.User> get members => _members;

  Future<void> _fetchTeamMembers() async {
    try {
      _isLoading = true;
      notifyListeners();

      List<model.User> fetchedMembers = [];
      for (var i = 0; i < team.members.length; i += 10) {
        var end = (i + 10 < team.members.length) ? i + 10 : team.members.length;
        var batch = team.members.sublist(i, end);

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: batch)
            .get();

        fetchedMembers.addAll(
            snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList());
      }

      _members = fetchedMembers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching team members: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTeamDetails() async {
    DocumentSnapshot teamDoc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(_team.uid)
        .get();
    _team = Team.fromSnap(teamDoc);
    await _fetchTeamMembers();
    notifyListeners();
  }
}
