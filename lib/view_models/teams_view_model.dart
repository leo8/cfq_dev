import 'package:flutter/material.dart';
import '../models/team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch teams where the current user is a member
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('members', arrayContains: currentUserId)
          .get();

      _teams = snapshot.docs.map((doc) => Team.fromSnap(doc)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      _isLoading = false;
      notifyListeners();
    }
  }
}
