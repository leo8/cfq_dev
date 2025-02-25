import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as model;
import '../models/team.dart';
import '../models/notification.dart' as notificationModel;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/styles/string.dart';
import '../utils/utils.dart';

class CreateTeamViewModel extends ChangeNotifier {
  // Team Name Controller
  final TextEditingController teamNameController = TextEditingController();

  // Team Image
  Uint8List? _teamImage;
  Uint8List? get teamImage => _teamImage;

  // Selected Friends
  final List<model.User> _selectedFriends = [];
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

  // Current User
  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  // Friends List
  List<model.User> _friendsList = [];
  List<model.User> get friendsList => _friendsList;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  CreateTeamViewModel() {
    _initializeCurrentUser();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeCurrentUser() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch current user data
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      _currentUser = model.User.fromSnap(userSnapshot);

      // Add current user to selected friends
      _selectedFriends.add(_currentUser!);

      // Fetch friends data
      List friendsUids = _currentUser!.friends;
      if (friendsUids.isNotEmpty) {
        QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: friendsUids)
            .get();

        _friendsList = friendsSnapshot.docs
            .map((doc) => model.User.fromSnap(doc))
            .toList();
      } else {
        _friendsList = [];
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing current user: $e');
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    teamNameController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> pickTeamImage(context) async {
    try {
      final ImageSource? source = await showImageSourceDialog(context);
      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);

        if (image != null) {
          _teamImage = await image.readAsBytes();
          notifyListeners();
        }
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
    _isSearching = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        // If query is empty, show all friends not already selected
        _searchResults = _friendsList
            .where((user) =>
                !_selectedFriends.any((f) => f.uid == user.uid) &&
                user.uid != _currentUser?.uid)
            .toList();
      } else {
        final queryLower = query.toLowerCase();
        _searchResults = _friendsList.where((user) {
          final searchKeyLower = user.searchKey;
          return searchKeyLower.startsWith(queryLower) &&
              !_selectedFriends.any((f) => f.uid == user.uid) &&
              user.uid != _currentUser?.uid;
        }).toList();
      }
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
    if (friend.uid != _currentUser?.uid) {
      _selectedFriends.removeWhere((user) => user.uid == friend.uid);
      notifyListeners();
    }
  }

  // Create Team
  Future<void> createTeam() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate required fields
      if (teamNameController.text.isEmpty) {
        _errorMessage = CustomString.pleaseEnterTeamName;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if at least one member (besides the current user) is selected
      if (_selectedFriends.length <= 1) {
        _errorMessage = CustomString.pleaseAddAtLeastOneMember;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Upload team image if provided
      String teamImageUrl = CustomString.emptyString;
      if (_teamImage != null) {
        teamImageUrl = await StorageMethods()
            .uploadImageToStorage('teamImages', _teamImage!, false);
      } else {
        // Use a default image URL or handle accordingly
        teamImageUrl =
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQx-RLO1096Hkl10EA9jQ6Il5_hQ3HtB2iIyg&s';
      }

      // Generate unique team ID
      String teamId = const Uuid().v4();

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
        members: [currentUserId],
        invitedCfqs: [],
        invitedTurns: [],
      );

      // Save team to Firestore
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .set(team.toJson());

      // Create pending requests for all selected friends except creator
      for (model.User friend in _selectedFriends) {
        if (friend.uid != _currentUser!.uid) {
          model.Request request = model.Request(
            id: const Uuid().v4(),
            type: model.RequestType.team,
            requesterId: _currentUser!.uid,
            requesterUsername: _currentUser!.username,
            requesterProfilePictureUrl: _currentUser!.profilePictureUrl,
            teamId: teamId,
            teamName: teamNameController.text,
            teamImageUrl: teamImageUrl,
            timestamp: DateTime.now(),
            status: model.RequestStatus.pending,
          );

          // Add request to user's requests array
          await FirebaseFirestore.instance
              .collection('users')
              .doc(friend.uid)
              .update({
            'requests': FieldValue.arrayUnion([request.toJson()])
          });

          // Create notification
          await _createTeamRequestNotification(
              friend.uid, teamId, teamImageUrl);
        }
      }

      // Update creator's teams array
      await _updateUsersTeams([_currentUser!.uid], teamId);

      _successMessage = CustomString.successCreatingTeam;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = CustomString.errorCreatingTeam;
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error creating team: $e');
    }
  }

  // Update 'teams' field for users
  Future<void> _updateUsersTeams(List<String> userIds, String teamId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String uid in userIds) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        batch.update(userRef, {
          'teams': FieldValue.arrayUnion([teamId])
        });
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error updating users\' teams: $e');
      rethrow; // Re-throw the error to be caught in createTeam()
    }
  }

  // Method to reset status messages
  void resetStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _createTeamRequestNotification(
      String userId, teamId, teamImageUrl) async {
    try {
      // Get the invited user's notification channel ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String notificationChannelId =
          (userDoc.data() as Map<String, dynamic>)['notificationsChannelId'];

      // Get current user data
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      Map<String, dynamic> currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.teamRequest
            .toString()
            .split('.')
            .last,
        'content': {
          'teamId': teamId,
          'teamName': teamNameController.text,
          'teamImageUrl': teamImageUrl ?? '',
          'inviterId': currentUserId,
          'inviterUsername': currentUserData['username'],
          'inviterProfilePictureUrl': currentUserData['profilePictureUrl'],
        },
      };

      // Add notification
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating team request notification: $e');
    }
  }
}
