import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/notification.dart' as notificationModel;
import '../models/team.dart';
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

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

  StreamSubscription<DocumentSnapshot>? _teamSubscription;
  StreamSubscription<QuerySnapshot>? _friendsSubscription;

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
    _initStreams();
  }

  Future<void> _initStreams() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Stream for team members
      _teamSubscription = FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .snapshots()
          .listen((teamDoc) {
        _teamMemberIds = List<String>.from(teamDoc['members']);
        _sortUsers();
      });

      // Get current user's friends first
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      List<String> friendIds = List<String>.from(userDoc['friends']);

      // Stream for friends
      _friendsSubscription = FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: friendIds)
          .snapshots()
          .listen((snapshot) {
        _friends =
            snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();
        _sortUsers();

        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      AppLogger.error('Error initializing streams: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _teamSubscription?.cancel();
    _friendsSubscription?.cancel();
    super.dispose();
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

      // Find existing request if any
      model.Request? existingRequest;
      try {
        existingRequest = user.requests.firstWhere(
          (request) =>
              request.type == model.RequestType.team &&
              request.teamId == teamId,
        );
      } catch (e) {
        existingRequest = null;
      }

      // Get team data
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();
      Team team = Team.fromSnap(teamDoc);

      // Get current user data
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      Map<String, dynamic> currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;

      // Create or update request
      if (existingRequest == null ||
          existingRequest.status == model.RequestStatus.denied) {
        // Remove old request if it exists
        if (existingRequest != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'requests': FieldValue.arrayRemove([existingRequest.toJson()])
          });
        }

        // Create new request
        model.Request newRequest = model.Request(
          id: existingRequest?.id ?? const Uuid().v4(),
          type: model.RequestType.team,
          requesterId: currentUserId,
          requesterUsername: currentUserData['username'],
          requesterProfilePictureUrl: currentUserData['profilePictureUrl'],
          teamId: teamId,
          teamName: team.name,
          teamImageUrl: team.imageUrl,
          timestamp: DateTime.now(),
          status: model.RequestStatus.pending,
        );

        // Add new request
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'requests': FieldValue.arrayUnion([newRequest.toJson()])
        });

        // Create notification
        final String notificationId = const Uuid().v4();
        final notification = {
          'id': notificationId,
          'timestamp': DateTime.now().toIso8601String(),
          'type': notificationModel.NotificationType.teamRequest
              .toString()
              .split('.')
              .last,
          'content': {
            'teamId': teamId,
            'teamName': team.name,
            'teamImageUrl': team.imageUrl,
            'inviterId': currentUserId,
            'inviterUsername': currentUserData['username'],
            'inviterProfilePictureUrl': currentUserData['profilePictureUrl'],
          },
        };

        // Add notification to user's notifications collection
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(userDoc['notificationsChannelId'])
            .collection('userNotifications')
            .doc(notificationId)
            .set(notification);

        // Increment unread notifications count
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'unreadNotificationsCount': FieldValue.increment(1),
        });

        _hasChanges = true;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error adding member to team: $e');
      rethrow;
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

  Future<model.Request?> getExistingRequest(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      model.User user = model.User.fromSnap(userDoc);

      try {
        return user.requests.firstWhere(
          (request) =>
              request.type == model.RequestType.team &&
              request.teamId == teamId,
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting existing request: $e');
      return null;
    }
  }
}
