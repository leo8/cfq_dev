import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../providers/user_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/notification.dart' as notificationModel;
import '../models/user.dart' as model;
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../providers/conversation_service.dart';
import '../models/conversation.dart';

class ExpandedCardViewModel extends ChangeNotifier {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String eventId;
  final String currentUserId;
  final bool isTurn;

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  // Add stream controllers
  StreamController<DocumentSnapshot>? _cfqStreamController;
  StreamController<int>? _attendingCountStreamController;
  StreamController<String>? _attendingStatusStreamController;
  StreamController<bool>? _isFollowingUpStreamController;
  StreamController<int>? _followersCountStreamController;

  final ConversationService _conversationService = ConversationService();

  bool _isFavorite = false;
  bool _isFollowingUp = false;
  int _followersCount = 0;
  bool _disposed = false;

  String? _channelId;
  String? get channelId => _channelId;

  ExpandedCardViewModel({
    required this.eventId,
    required this.currentUserId,
    required this.isTurn,
  }) {
    if (eventId.isEmpty) {
      AppLogger.error('Empty event ID provided to ExpandedCardViewModel');
      throw ArgumentError('Event ID cannot be empty');
    }

    _initializeData();
    _initializeStreams();
  }

  // Initialize all streams
  void _initializeStreams() {
    _cfqStreamController = StreamController<DocumentSnapshot>();
    _attendingCountStreamController = StreamController<int>();
    _attendingStatusStreamController = StreamController<String>();
    _isFollowingUpStreamController = StreamController<bool>();
    _followersCountStreamController = StreamController<int>();
  }

  @override
  void dispose() {
    _disposed = true;
    _cfqStreamController?.close();
    _attendingCountStreamController?.close();
    _attendingStatusStreamController?.close();
    _isFollowingUpStreamController?.close();
    _followersCountStreamController?.close();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool get isFavorite => _isFavorite;
  bool get isFollowingUp => _isFollowingUp;
  int get followersCount => _followersCount;

  Future<void> _initializeData() async {
    try {
      final eventDoc = await _firestore
          .collection(isTurn ? 'turns' : 'cfqs')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        AppLogger.error('Event document not found: $eventId');
        throw Exception('Event not found');
      }

      // Get channel ID from event document
      final eventData = eventDoc.data() as Map<String, dynamic>;
      _channelId = eventData['channelId'];

      // Get current user data
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      _currentUser = model.User.fromSnap(userDoc);

      // Initialize other streams
      _fetchAttendingStatus();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing expanded card data: $e');
      rethrow;
    }
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      List<dynamic> favorites =
          (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
      _isFavorite = favorites.contains(eventId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching favorite status: $e');
    }
  }

  Future<void> _fetchFollowUpStatus() async {
    if (!isTurn) {
      try {
        DocumentSnapshot cfqDoc =
            await _firestore.collection('cfqs').doc(eventId).get();
        List<dynamic> followingUp =
            (cfqDoc.data() as Map<String, dynamic>)['followingUp'] ?? [];
        _isFollowingUp = followingUp.contains(currentUserId);
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error fetching follow-up status: $e');
      }
    }
  }

  Future<void> _fetchFollowersCount() async {
    if (!isTurn) {
      try {
        DocumentSnapshot cfqDoc =
            await _firestore.collection('cfqs').doc(eventId).get();
        List<dynamic> followingUp =
            (cfqDoc.data() as Map<String, dynamic>)['followingUp'] ?? [];
        _followersCount = followingUp.length;
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error fetching followers count: $e');
      }
    }
  }

  Future<void> toggleFavorite() async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);

      // Update Firestore
      if (_isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([eventId])
        });
      }

      // Update local state
      _isFavorite = !_isFavorite;
      notifyListeners();

      // Add this line to update UserProvider
      UserProvider().refreshUser();
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
    }
  }

  Stream<int> get attendingCountStream {
    if (!isTurn) return Stream.value(0);

    return _firestore
        .collection('turns')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['attending'] as List?)?.length ?? 0;
    });
  }

  Stream<String> get attendingStatusStream {
    if (!isTurn) return Stream.value('notAnswered');

    return _firestore
        .collection('turns')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 'notAnswered';
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['attending']?.contains(currentUserId) ?? false)
        return 'attending';
      if (data['notSureAttending']?.contains(currentUserId) ?? false)
        return 'notSureAttending';
      if (data['notAttending']?.contains(currentUserId) ?? false)
        return 'notAttending';
      return 'notAnswered';
    });
  }

  Future<void> updateAttendingStatus(String status) async {
    if (_disposed) return;

    try {
      final batch = _firestore.batch();
      final turnRef = _firestore.collection('turns').doc(eventId);
      final userRef = _firestore.collection('users').doc(currentUserId);

      final turnDoc = await turnRef.get();
      final userDoc = await userRef.get();

      if (!turnDoc.exists || !userDoc.exists) {
        throw Exception('Turn or User document does not exist');
      }

      final turnData = turnDoc.data()!;
      final userData = userDoc.data()!;

      // Remove user from all lists first
      final List<String> attending =
          List<String>.from(turnData['attending'] ?? []);
      final List<String> notAttending =
          List<String>.from(turnData['notAttending'] ?? []);
      final List<String> notSureAttending =
          List<String>.from(turnData['notSureAttending'] ?? []);

      attending.remove(currentUserId);
      notAttending.remove(currentUserId);
      notSureAttending.remove(currentUserId);

      // Add user to appropriate list only if not unselecting
      if (status != 'notAnswered') {
        switch (status) {
          case 'attending':
            attending.add(currentUserId);
            break;
          case 'notAttending':
            notAttending.add(currentUserId);
            break;
          case 'notSureAttending':
            notSureAttending.add(currentUserId);
            break;
        }
      }

      // Update turn document
      batch.update(turnRef, {
        'attending': attending,
        'notAttending': notAttending,
        'notSureAttending': notSureAttending,
      });

      // Update user's attending status
      Map<String, dynamic> attendingStatus =
          Map<String, dynamic>.from(userData['attendingStatus'] ?? {});
      if (status == 'notAnswered') {
        attendingStatus.remove(eventId);
      } else {
        attendingStatus[eventId] = status;
      }
      batch.update(userRef, {'attendingStatus': attendingStatus});

      await batch.commit();

      if (_disposed) return;
      final organizerId = turnData['uid'] as String;

      // Create notification if attending
      if (status == 'attending' && organizerId != currentUserId) {
        await _createAttendingNotification(eventId);
      }

      String channelId = turnData['channelId'] as String;

      if (status == 'attending') {
        bool hasConversation =
            await _conversationService.isConversationInUserList(
          _currentUser!.uid,
          channelId,
        );

        if (!hasConversation) {
          await _conversationService.addConversationToUser(
            _currentUser!.uid,
            channelId,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      if (!_disposed) {
        AppLogger.error('Error updating attending status: $e');
      }
    }
  }

  Stream<bool> get isFollowingUpStream {
    if (!isTurn) {
      return _firestore
          .collection('cfqs')
          .doc(eventId)
          .snapshots()
          .map((snapshot) {
        List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
        return followingUp.contains(currentUserId);
      });
    } else {
      return Stream.value(false);
    }
  }

  Future<void> _createFollowUpNotification(String cfqId) async {
    try {
      // Get the CFQ document to get the organizer's ID and following users
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> cfqData = cfqSnapshot.data() as Map<String, dynamic>;
      List<String> followingUsers =
          List<String>.from(cfqData['followingUp'] ?? []);

      // Remove current user from notification recipients
      followingUsers.remove(currentUserId);

      if (followingUsers.isEmpty) return;

      // Get current user data
      DocumentSnapshot currentUserSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();
      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      // Create the base notification object
      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.followUp
            .toString()
            .split('.')
            .last,
        'content': {
          'cfqId': cfqId,
          'cfqName': cfqData['cfqName'] as String,
          'followerId': currentUserId,
          'followerUsername': currentUserData['username'],
          'followerProfilePictureUrl': currentUserData['profilePictureUrl'],
        },
      };

      // Create a batch for all operations
      WriteBatch batch = _firestore.batch();

      // Get all following users' notification channels and create notifications
      QuerySnapshot userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followingUsers)
          .get();

      for (DocumentSnapshot userDoc in userDocs.docs) {
        String notificationChannelId =
            (userDoc.data() as Map<String, dynamic>)['notificationsChannelId'];

        // Add notification to user's notification channel
        DocumentReference notificationRef = _firestore
            .collection('notifications')
            .doc(notificationChannelId)
            .collection('userNotifications')
            .doc();

        batch.set(notificationRef, notification);

        // Increment unread notifications count
        DocumentReference userRef =
            _firestore.collection('users').doc(userDoc.id);
        batch.update(userRef, {
          'unreadNotificationsCount': FieldValue.increment(1),
        });
      }

      // Commit all operations
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error creating follow-up notification: $e');
    }
  }

  static Future<void> addFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      AppLogger.error('Error adding follow-up: $e');
      rethrow;
    }
  }

  static Future<void> removeFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      AppLogger.error('Error removing follow-up: $e');
      rethrow;
    }
  }

  Future<void> toggleFollowUp(String cfqId, String userId) async {
    try {
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
      List<dynamic> followingUp = data['followingUp'] ?? [];
      String channelId = data['channelId'] as String;
      AppLogger.debug('channelId: $channelId');

      if (followingUp.contains(userId)) {
        await removeFollowUp(cfqId, userId);
      } else {
        await addFollowUp(cfqId, userId);
        // Create notification only when following up, not when removing
        await _createFollowUpNotification(
          cfqId,
        );
        bool hasConversation =
            await _conversationService.isConversationInUserList(
          userId,
          channelId,
        );

        if (!hasConversation) {
          await _conversationService.addConversationToUser(
            userId,
            channelId,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> get cfqStream {
    return _firestore.collection('cfqs').doc(eventId).snapshots();
  }

  Future<void> _createAttendingNotification(String turnId) async {
    try {
      // Get the turn document to get the organizer's ID and name
      DocumentSnapshot turnSnapshot =
          await _firestore.collection('turns').doc(turnId).get();
      Map<String, dynamic> turnData =
          turnSnapshot.data() as Map<String, dynamic>;
      String organizerId = turnData['uid'] as String;
      String turnName = turnData['turnName'] as String;

      // Get current user data
      DocumentSnapshot currentUserSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();
      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      // Get the organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(organizerId).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.attending
            .toString()
            .split('.')
            .last,
        'content': {
          'turnId': turnId,
          'turnName': turnName,
          'attendingId': currentUserId,
          'attendingUsername': currentUserData['username'],
          'attendingProfilePictureUrl': currentUserData['profilePictureUrl'],
        },
      };

      // Add notification to organizer's notification channel
      await _firestore
          .collection('notifications')
          .doc(organizerNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count for the organizer
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating attending notification: $e');
    }
  }

  Stream<int> get followersCountStream {
    return _firestore
        .collection('cfqs')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['followingUp'] as List?)?.length ?? 0;
    });
  }

  Future<void> deleteTurn() async {
    if (!isTurn) return;

    try {
      // Get turn data before deletion
      final turnDoc = await _firestore.collection('turns').doc(eventId).get();
      if (!turnDoc.exists) {
        throw Exception('Turn document does not exist');
      }

      final turnData = turnDoc.data()!;
      final String? channelId = turnData['channelId'];
      final List<String> invitees =
          List<String>.from(turnData['invitees'] ?? []);
      final List<String> teamInvitees =
          List<String>.from(turnData['teamInvitees'] ?? []);

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // 1. Delete the turn document
      batch.delete(_firestore.collection('turns').doc(eventId));

      // 2. Delete the associated conversation if it exists
      if (channelId != null) {
        batch.delete(_firestore.collection('conversations').doc(channelId));
      }

      // 3. Remove turnId from organizer's postedTurns
      batch.update(
        _firestore.collection('users').doc(currentUserId),
        {
          'postedTurns': FieldValue.arrayRemove([eventId])
        },
      );

      // 4. Remove turnId from all invited users' invitedTurns and attendingStatus
      for (String userId in invitees) {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {
          'invitedTurns': FieldValue.arrayRemove([eventId]),
          'attendingStatus.$eventId': FieldValue.delete(),
        });
      }

      // 5. Remove turnId from all invited teams' invitedTurns
      for (String teamId in teamInvitees) {
        DocumentReference teamRef = _firestore.collection('teams').doc(teamId);
        batch.update(teamRef, {
          'invitedTurns': FieldValue.arrayRemove([eventId]),
        });
      }

      // 6. Remove turnId from invitees' favorites if present
      for (String userId in invitees) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          List<String> favorites = List<String>.from(
              (userDoc.data() as Map<String, dynamic>)['favorites'] ?? []);
          if (favorites.contains(eventId)) {
            batch.update(userDoc.reference, {
              'favorites': FieldValue.arrayRemove([eventId])
            });
          }
        }
      }

      // Check organizer's favorites
      DocumentSnapshot organizerDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (organizerDoc.exists) {
        List<String> favorites = List<String>.from(
            (organizerDoc.data() as Map<String, dynamic>)['favorites'] ?? []);
        if (favorites.contains(eventId)) {
          batch.update(organizerDoc.reference, {
            'favorites': FieldValue.arrayRemove([eventId])
          });
        }
      }

      // Commit all the batch operations
      await batch.commit();

      // Update UserProvider to refresh the UI
      UserProvider().refreshUser();
    } catch (e) {
      AppLogger.error('Error deleting turn: $e');
      rethrow;
    }
  }

  Future<void> deleteCfq() async {
    if (isTurn) return;

    try {
      // Get CFQ data before deletion
      final cfqDoc = await _firestore.collection('cfqs').doc(eventId).get();
      if (!cfqDoc.exists) {
        throw Exception('CFQ document does not exist');
      }

      final cfqData = cfqDoc.data()!;
      final String? channelId = cfqData['channelId'];
      final List<String> invitees =
          List<String>.from(cfqData['invitees'] ?? []);
      final List<String> teamInvitees =
          List<String>.from(cfqData['teamInvitees'] ?? []);

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // 1. Delete the CFQ document
      batch.delete(_firestore.collection('cfqs').doc(eventId));

      // 2. Delete the associated conversation if it exists
      if (channelId != null) {
        batch.delete(_firestore.collection('conversations').doc(channelId));
      }

      // 3. Remove cfqId from organizer's postedCfqs
      batch.update(
        _firestore.collection('users').doc(currentUserId),
        {
          'postedCfqs': FieldValue.arrayRemove([eventId])
        },
      );

      // 4. Remove cfqId from all invited users' invitedCfqs
      for (String userId in invitees) {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {
          'invitedCfqs': FieldValue.arrayRemove([eventId]),
        });
      }

      // 5. Remove cfqId from all invited teams' invitedCfqs
      for (String teamId in teamInvitees) {
        DocumentReference teamRef = _firestore.collection('teams').doc(teamId);
        batch.update(teamRef, {
          'invitedCfqs': FieldValue.arrayRemove([eventId]),
        });
      }

      // 6. Remove cfqId from invitees' favorites if present
      for (String userId in invitees) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          List<String> favorites = List<String>.from(
              (userDoc.data() as Map<String, dynamic>)['favorites'] ?? []);
          if (favorites.contains(eventId)) {
            batch.update(userDoc.reference, {
              'favorites': FieldValue.arrayRemove([eventId])
            });
          }
        }
      }

      // Check organizer's favorites
      DocumentSnapshot organizerDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (organizerDoc.exists) {
        List<String> favorites = List<String>.from(
            (organizerDoc.data() as Map<String, dynamic>)['favorites'] ?? []);
        if (favorites.contains(eventId)) {
          batch.update(organizerDoc.reference, {
            'favorites': FieldValue.arrayRemove([eventId])
          });
        }
      }

      // Commit all the batch operations
      await batch.commit();

      // Update UserProvider to refresh the UI
      UserProvider().refreshUser();
    } catch (e) {
      AppLogger.error('Error deleting CFQ: $e');
      rethrow;
    }
  }

  Future<bool> isConversationInUserList() async {
    if (_channelId == null) return false;
    return await _conversationService.isConversationInUserList(
        currentUserId, _channelId!);
  }

  Future<void> _fetchAttendingStatus() async {
    try {
      if (!isTurn) return;

      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final attendingEvents =
          List<String>.from(userData['attendingEvents'] ?? []);
      final notAttendingEvents =
          List<String>.from(userData['notAttendingEvents'] ?? []);

      String status = 'notAnswered';
      if (attendingEvents.contains(eventId)) {
        status = 'attending';
      } else if (notAttendingEvents.contains(eventId)) {
        status = 'notAttending';
      }

      _attendingStatusStreamController?.add(status);
    } catch (e) {
      AppLogger.error('Error fetching attending status: $e');
    }
  }

  Future<void> loadConversations() async {
    _conversations =
        await _conversationService.getUserConversations(currentUserId);
    notifyListeners();
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(currentUserId, channelId);
    await loadConversations();
    notifyListeners();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUserId, channelId);
    await loadConversations();
    notifyListeners();
  }

  Future<void> resetUnreadMessages(String conversationId) async {
    try {
      await _conversationService.resetUnreadMessages(
          currentUserId, conversationId);
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
      rethrow;
    }
  }
}
