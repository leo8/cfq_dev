import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/notification.dart' as notificationModel;
import '../models/team.dart';
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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

  final TextEditingController searchController = TextEditingController();
  List<model.User> _allNonTeamMembers = [];

  void _sortUsers() {
    _teamMembers = _friends
        .where((friend) => _teamMemberIds.contains(friend.uid))
        .toList();
    _allNonTeamMembers = _friends
        .where((friend) => !_teamMemberIds.contains(friend.uid))
        .toList();
    _nonTeamMembers = _allNonTeamMembers;
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
      // Check for existing request
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      model.User user = model.User.fromSnap(userDoc);
      model.Request? existingRequest = user.requests.firstWhere(
        (request) =>
            request.type == model.RequestType.team && request.teamId == teamId,
      );

      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      Team team = Team.fromSnap(teamDoc);

      if (existingRequest.status == model.RequestStatus.denied) {
        // Create new request or update existing one
        model.Request request = model.Request(
          id: existingRequest.id,
          type: model.RequestType.team,
          requesterId: FirebaseAuth.instance.currentUser!.uid,
          requesterUsername: user.username,
          requesterProfilePictureUrl: user.profilePictureUrl,
          teamId: teamId,
          teamName: team.name,
          teamImageUrl: team.imageUrl,
          timestamp: DateTime.now(),
          status: model.RequestStatus.pending,
        );

        // Add new/updated request
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'requests': FieldValue.arrayUnion([request.toJson()])
        });

        // Create notification
        await _createTeamRequestNotification(userId, teamId);

        _hasChanges = true;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error adding member to team: $e');
    }
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      _nonTeamMembers = _allNonTeamMembers;
    } else {
      _nonTeamMembers = _allNonTeamMembers
          .where((friend) =>
              friend.username.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _createTeamRequestNotification(String userId, teamId) async {
    try {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

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
        'timestamp': FieldValue.serverTimestamp(),
        'type': notificationModel.NotificationType.teamRequest
            .toString()
            .split('.')
            .last,
        'content': {
          'teamId': teamId,
          'teamName': teamDoc['teamName'] ?? '',
          'teamImageUrl': teamDoc['teamImageUrl'] ?? '',
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
