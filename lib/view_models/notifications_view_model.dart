import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/conversation_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/notification.dart' as notificationModel;
import '../models/user.dart' as model;
import '../utils/logger.dart';
import '../utils/date_time_utils.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class NotificationsViewModel extends ChangeNotifier {
  final String currentUserUid;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<notificationModel.Notification> _notifications = [];
  bool _isLoading = true;
  StreamSubscription? _unreadCountSubscription;
  int _unreadNotificationsCount = 0;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final BehaviorSubject<int> _unreadConversationsCountSubject =
      BehaviorSubject<int>.seeded(0);
  Stream<int> get unreadConversationsCountStream =>
      _unreadConversationsCountSubject.stream;

  final BehaviorSubject<int> _unreadNotificationsCountSubject =
      BehaviorSubject<int>.seeded(0);
  Stream<int> get unreadNotificationsCountStream =>
      _unreadNotificationsCountSubject.stream;

  final ConversationService _conversationService = ConversationService();

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  int get unreadNotificationsCount => _unreadNotificationsCount;

  List<notificationModel.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  Stream<int> get unreadCountStream => _firestore
      .collection('users')
      .doc(currentUserUid)
      .snapshots()
      .map((snapshot) => snapshot.get('unreadNotificationsCount') ?? 0);

  NotificationsViewModel({required this.currentUserUid}) {
    _loadNotifications();
    _setupUnreadCountStream();
    _initializeCurrentUser();
  }

  Future<void> _loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userDoc =
          await _firestore.collection('users').doc(currentUserUid).get();
      final String notificationChannelId =
          userDoc.get('notificationsChannelId');

      final querySnapshot = await _firestore
          .collection('notifications')
          .doc(notificationChannelId)
          .collection('userNotifications')
          .orderBy('timestamp', descending: true)
          .get();

      AppLogger.debug('Found ${querySnapshot.docs.length} notifications');
      AppLogger.debug(
          'Notification types: ${querySnapshot.docs.map((doc) => (doc.data()['type'] as String)).toList()}');

      _notifications = await Future.wait(querySnapshot.docs.map((doc) async {
        final notification = notificationModel.Notification.fromSnap(doc);

        // Enrich notification content with additional data if needed
        switch (notification.type) {
          case notificationModel.NotificationType.followUp:
          case notificationModel.NotificationType.eventInvitation:
          case notificationModel.NotificationType.attending:
            return notification;

          case notificationModel.NotificationType.teamRequest:
          case notificationModel.NotificationType.friendRequest:
            // These don't need additional data for navigation
            return notification;

          default:
            return notification;
        }
      }).toList());

      AppLogger.debug('Filtered to ${_notifications.length} notifications');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading notifications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupUnreadCountStream() {
    _unreadCountSubscription = _firestore
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
      _unreadNotificationsCount = snapshot.get('unreadNotificationsCount') ?? 0;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    _userSubscription!.cancel();
    super.dispose();
  }

  Future<void> resetUnreadCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({'unreadNotificationsCount': 0});
    } catch (e) {
      AppLogger.error('Error resetting unread notifications count: $e');
    }
  }

  DateTime getEventDateTime(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime result;
    if (doc.reference.parent.id == 'turns') {
      result = DateTimeUtils.parseDate(data['eventDateTime']);
    } else {
      result = data['eventDateTime'] != null
          ? DateTimeUtils.parseDate(data['eventDateTime'])
          : DateTimeUtils.parseDate(data['datePublished']);
    }
    return result;
  }

  DateTime getPublishedDateTime(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime result;
    result = DateTimeUtils.parseDate(data['datePublished']);
    return result;
  }

  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserUid);

      if (isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([eventId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
      }

      if (_currentUser != null) {
        if (isFavorite) {
          _currentUser!.favorites.add(eventId);
        } else {
          _currentUser!.favorites.remove(eventId);
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
    }
  }

  void _listenToUserChanges() {
    _userSubscription = _firestore
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentUser = model.User.fromSnap(snapshot);

        // Update notifications count
        _unreadNotificationsCountSubject
            .add(_currentUser?.unreadNotificationsCount ?? 0);

        // Update conversations count
        final unreadConversationsCount = _currentUser?.conversations
                .where((conv) => conv.unreadMessagesCount > 0)
                .length ??
            0;
        _unreadConversationsCountSubject.add(unreadConversationsCount);

        notifyListeners();
      }
    });
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(currentUserUid, channelId);
    notifyListeners();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUserUid, channelId);
    notifyListeners();
  }

  Future<void> resetUnreadMessages(String conversationId) async {
    try {
      await _conversationService.resetUnreadMessages(
          currentUserUid, conversationId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
    }
  }

  Future<bool> isConversationInUserList(String channelId) async {
    return await _conversationService.isConversationInUserList(
        currentUserUid, channelId);
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

      // Get organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(data['uid'] as String).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      if (followingUp.contains(userId)) {
        await removeFollowUp(cfqId, userId);
      } else {
        await addFollowUp(cfqId, userId);
        // Create notification only when following up, not when removing
        await _createFollowUpNotification(
          cfqId,
          data['cfqName'] as String,
          organizerNotificationChannelId,
        );
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
    }
  }

  Future<void> _createAttendingNotification(String turnId) async {
    try {
      if (_currentUser == null) return;

      // Get the turn document to get the organizer's ID and name
      DocumentSnapshot turnSnapshot =
          await _firestore.collection('turns').doc(turnId).get();
      Map<String, dynamic> turnData =
          turnSnapshot.data() as Map<String, dynamic>;
      String organizerId = turnData['uid'] as String;
      String turnName = turnData['turnName'] as String;

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
          'attendingId': _currentUser!.uid,
          'attendingUsername': _currentUser!.username,
          'attendingProfilePictureUrl': _currentUser!.profilePictureUrl,
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

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(currentUserUid);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot turnDoc = await transaction.get(turnRef);
        DocumentSnapshot userDoc = await transaction.get(userRef);

        if (!turnDoc.exists) {
          throw Exception('Turn document does not exist');
        }

        Map<String, dynamic> turnData = turnDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Remove user from all attending lists
        ['attending', 'notSureAttending', 'notAttending', 'notAnswered']
            .forEach((field) {
          if (turnData[field] != null) {
            turnData[field] = (turnData[field] as List)
                .where((id) => id != currentUserUid)
                .toList();
          }
        });

        // Add user to the appropriate list
        if (status != 'notAnswered') {
          turnData[status] = [...(turnData[status] ?? []), currentUserUid];
        }

        // Update user's attending status for this turn
        if (userData['attendingStatus'] == null) {
          userData['attendingStatus'] = {};
        }
        userData['attendingStatus'][turnId] = status;

        transaction.update(turnRef, turnData);
        transaction.update(userRef, userData);
      });

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating attending status: $e');
    }
  }

  Stream<String> attendingStatusStream(String turnId, String userId) {
    return _firestore
        .collection('turns')
        .doc(turnId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 'notAnswered';
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['attending']?.contains(userId) ?? false) return 'attending';
      if (data['notSureAttending']?.contains(userId) ?? false)
        return 'notSureAttending';
      if (data['notAttending']?.contains(userId) ?? false)
        return 'notAttending';
      return 'notAnswered';
    });
  }

  Stream<int> attendingCountStream(String turnId) {
    return _firestore
        .collection('turns')
        .doc(turnId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['attending'] as List?)?.length ?? 0;
    });
  }

  Stream<bool> isFollowingUpStream(String cfqId, String userId) {
    return _firestore.collection('cfqs').doc(cfqId).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      final followingUp = List<String>.from(data['followingUp'] ?? []);
      return followingUp.contains(userId);
    });
  }

  Future<void> _createFollowUpNotification(
    String cfqId,
    String cfqName,
    String organizerNotificationChannelId,
  ) async {
    try {
      if (_currentUser == null) return;

      // Get the CFQ document to get the organizer's ID
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      String organizerId =
          (cfqSnapshot.data() as Map<String, dynamic>)['uid'] as String;

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.followUp
            .toString()
            .split('.')
            .last,
        'content': {
          'cfqId': cfqId,
          'cfqName': cfqName,
          'followerId': _currentUser!.uid,
          'followerUsername': _currentUser!.username,
          'followerProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification to organizer's notification channel
      await _firestore
          .collection('notifications')
          .doc(organizerNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count for the organizer using their user ID
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating follow-up notification: $e');
    }
  }

  // Add these new methods for real-time event data
  Stream<DocumentSnapshot> getEventStream(String eventId, bool isTurn) {
    final collection = isTurn ? 'turns' : 'cfqs';
    return _firestore.collection(collection).doc(eventId).snapshots();
  }

  Future<void> _initializeCurrentUser() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserUid).get();
      if (userDoc.exists) {
        _currentUser = model.User.fromSnap(userDoc);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error initializing current user: $e');
    }
  }

  Future<model.User> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;

    final userDoc =
        await _firestore.collection('users').doc(currentUserUid).get();
    _currentUser = model.User.fromSnap(userDoc);
    return _currentUser!;
  }
}
