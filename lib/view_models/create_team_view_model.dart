import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as model;
import '../models/team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import '../utils/styles/string.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTeamViewModel extends ChangeNotifier {
  // Team Name Controller
  final TextEditingController teamNameController = TextEditingController();

  // Team Image
  Uint8List? _teamImage;
  Uint8List? get teamImage => _teamImage;

  // Selected Friends
  List<model.User> _selectedFriends = [];
  List<model.User> get selectedFriends => _selectedFriends;

  // Search
  final TextEditingController searchController = TextEditingController();
  List<model.User> _searchResults = [];
  List<model.User> get searchResults => _searchResults;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // Status Messages
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Constructor
  CreateTeamViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    teamNameController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> pickTeamImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _teamImage = await image.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error picking team image: $e');
    }
  }

  // Search Functionality
  void _onSearchChanged() {
    performSearch(searchController.text);
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Query Firestore for users matching the search query
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('searchKey', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('searchKey',
              isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .get();

      List<model.User> users =
          snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();

      // Remove already selected friends
      _searchResults = users
          .where((user) => !_selectedFriends.any((f) => f.uid == user.uid))
          .toList();
    } catch (e) {
      AppLogger.error('Error while searching users: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  // Add Friend to Selected List
  void addFriend(model.User friend) {
    _selectedFriends.add(friend);
    _searchResults.removeWhere((user) => user.uid == friend.uid);
    notifyListeners();
  }

  // Remove Friend from Selected List
  void removeFriend(model.User friend) {
    _selectedFriends.removeWhere((user) => user.uid == friend.uid);
    notifyListeners();
  }

  // Create Team
  Future<void> createTeam() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate required fields
      if (teamNameController.text.isEmpty) {
        _errorMessage = 'Please enter a team name.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (_selectedFriends.isEmpty) {
        _errorMessage = 'Please select at least one member.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Upload team image if provided
      String teamImageUrl = '';
      if (_teamImage != null) {
        teamImageUrl = await StorageMethods()
            .uploadImageToStorage('teamImages', _teamImage!, false);
      } else {
        // Use a default image URL or handle accordingly
        teamImageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQx-RLO1096Hkl10EA9jQ6Il5_hQ3HtB2iIyg&s';
      }

      // Generate unique team ID
      String teamId = const Uuid().v1();

      // Get current user UID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Collect member UIDs (including current user)
      List<String> memberUids =
          _selectedFriends.map((user) => user.uid).toList();
      if (!memberUids.contains(currentUserId)) {
        memberUids.add(currentUserId);
      }

      // Create Team object
      Team team = Team(
        uid: teamId,
        name: teamNameController.text.trim(),
        imageUrl: teamImageUrl,
        members: memberUids,
      );

      // Save team to Firestore
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .set(team.toJson());

      // Update teams list for current user and selected friends
      await _updateUsersTeams(memberUids, teamId);

      // Success
      _successMessage = 'Team created successfully!';
      _isLoading = false;
      notifyListeners();

      // Optionally, reset the form or navigate back
    } catch (e) {
      AppLogger.error('Error creating team: $e');
      _errorMessage = 'Failed to create team. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update 'teams' field for users
  Future<void> _updateUsersTeams(List<String> userIds, String teamId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String uid in userIds) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      batch.update(userRef, {
        'teams': FieldValue.arrayUnion([teamId])
      });
    }

    await batch.commit();
  }

  // Method to reset status messages
  void resetStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
