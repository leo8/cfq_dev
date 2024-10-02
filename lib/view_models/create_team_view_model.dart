import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import 'dart:io';

class CreateTeamViewModel extends ChangeNotifier {
  // Team Name Controller
  final TextEditingController teamNameController = TextEditingController();

  // Team Image
  File? _teamImage;
  File? get teamImage => _teamImage;

  // Selected Friends
  List<model.User> _selectedFriends = [];
  List<model.User> get selectedFriends => _selectedFriends;

  // Search
  final TextEditingController searchController = TextEditingController();
  List<model.User> _searchResults = [];
  List<model.User> get searchResults => _searchResults;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

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
        _teamImage = File(image.path);
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
    // Implement team creation logic
    // Upload team image to storage
    // Save team data to Firestore
    // Handle errors and success status
  }
}
