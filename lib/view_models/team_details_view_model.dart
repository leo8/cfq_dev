import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';

class TeamDetailsViewModel extends ChangeNotifier {
  final Team team;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<model.User> _members = [];
  List<model.User> get members => _members;

  TeamDetailsViewModel({required this.team}) {
    fetchTeamMembers();
  }

  Future<void> fetchTeamMembers() async {
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
}
