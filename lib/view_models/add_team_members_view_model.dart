import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeamMembersViewModel extends ChangeNotifier {
  final String teamId;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<model.User> _friends = [];
  List<model.User> get friends => _friends;

  List<String> _teamMembers = [];

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

      _teamMembers = List<String>.from(teamDoc['members']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isTeamMember(String userId) {
    return _teamMembers.contains(userId);
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

      _teamMembers.add(userId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error adding member to team: $e');
    }
  }
}
