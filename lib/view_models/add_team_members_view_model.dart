import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeamMembersViewModel extends ChangeNotifier {
  final String teamId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  List<model.User> _friends = [];
  List<model.User> get friends => _friends;

  List<String> _teamMemberIds = [];
  List<model.User> _teamMembers = [];
  List<model.User> _nonTeamMembers = [];

  List<model.User> get teamMembers => _teamMembers;
  List<model.User> get nonTeamMembers => _nonTeamMembers;

  void _sortUsers() {
    _teamMembers = _friends
        .where((friend) => _teamMemberIds.contains(friend.uid))
        .toList();
    _nonTeamMembers = _friends
        .where((friend) => !_teamMemberIds.contains(friend.uid))
        .toList();
    notifyListeners();
  }

  AddTeamMembersViewModel({required this.teamId}) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch current user's friends
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      List<String> friendIds = List<String>.from(userDoc['friends']);

      // Fetch friend details
      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: friendIds)
          .get();

      _friends =
          friendsSnapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();

      // Fetch team members
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      _teamMemberIds = List<String>.from(teamDoc['members']);

      _sortUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isTeamMember(String userId) {
    return _teamMemberIds.contains(userId);
  }

  Future<void> addMemberToTeam(String userId) async {
    try {
      // Update team document
      await FirebaseFirestore.instance.collection('teams').doc(teamId).update({
        'members': FieldValue.arrayUnion([userId])
      });

      // Update user document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'teams': FieldValue.arrayUnion([teamId])
      });

      _teamMemberIds.add(userId);
      _hasChanges = true;
      _sortUsers();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error adding member to team: $e');
    }
  }
}
