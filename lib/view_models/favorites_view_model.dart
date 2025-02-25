import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../utils/logger.dart';
import '../providers/conversation_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/notification.dart' as notificationModel;
import 'package:uuid/uuid.dart';
import 'dart:async';

class FavoritesViewModel extends ChangeNotifier {
  final String currentUserId;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  model.User? _currentUser;
  List<DocumentSnapshot> _favoriteEvents = [];
  bool _isLoading = true;
  bool _disposed = false;
  StreamSubscription? _favoritesSubscription;

  FavoritesViewModel({required this.currentUserId}) {
    _initializeData();
  }

  model.User? get currentUser => _currentUser;

  List<DocumentSnapshot> get favoriteEvents => _favoriteEvents;
  bool get isLoading => _isLoading;

  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  Future<void> _initializeData() async {
    await _fetchCurrentUser();
    await _fetchFavoriteEvents();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      _currentUser = model.User.fromSnap(userSnap);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching current user: $e');
    }
  }

  Future<void> _fetchFavoriteEvents() async {
    if (_disposed) return;
    _isLoading = true;
    if (!_disposed) notifyListeners();

    try {
      if (_currentUser == null || _currentUser!.favorites.isEmpty) {
        _favoriteEvents = [];
        _isLoading = false;
        if (!_disposed) notifyListeners();
        return;
      }

      Map<String, DocumentSnapshot> eventsMap = {};

      // Fetch and filter turns
      (await FirebaseFirestore.instance
              .collection('turns')
              .where('turnId', whereIn: _currentUser!.favorites)
              .get())
          .docs
          .where((doc) => !isEventExpired(doc))
          .forEach((doc) => eventsMap[doc['turnId']] = doc);

      // Fetch and filter cfqs
      (await FirebaseFirestore.instance
              .collection('cfqs')
              .where('cfqId', whereIn: _currentUser!.favorites)
              .get())
          .docs
          .where((doc) => !isEventExpired(doc))
          .forEach((doc) => eventsMap[doc['cfqId']] = doc);

      _favoriteEvents = _currentUser!.favorites
          .map((id) => eventsMap[id])
          .where((doc) => doc != null)
          .cast<DocumentSnapshot<Object?>>()
          .toList()
          .reversed
          .toList();

      _isLoading = false;
      if (!_disposed) notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error('Error fetching favorite events: $e');
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      if (!isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
        _currentUser!.favorites.remove(eventId);
        _favoriteEvents.removeWhere((event) {
          // Check for both turnId and cfqId
          return (event.data() as Map<String, dynamic>).containsKey('turnId')
              ? event['turnId'] == eventId
              : event['cfqId'] == eventId;
        });
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
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

  Future<bool> isConversationInUserList(String channelId) async {
    return await _conversationService.isConversationInUserList(
        currentUserId, channelId);
  }

  Future<void> resetUnreadMessages(String conversationId) async {
    try {
      await _conversationService.resetUnreadMessages(
          currentUser!.uid, conversationId);
      // Update the local state
      int index = currentUser!.conversations
          .indexWhere((conv) => conv.conversationId == conversationId);
      if (index != -1) {
        currentUser!.conversations[index].unreadMessagesCount = 0;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
    }
  }

  static Future<void> addFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      AppLogger.debug('Error adding follow-up: $e');
      // You might want to rethrow the error or handle it differently
      rethrow;
    }
  }

  static Future<void> removeFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      AppLogger.debug('Error removing follow-up: $e');
      // You might want to rethrow the error or handle it differently
      rethrow;
    }
  }

  Stream<bool> isFollowingUpStream(String documentId, String userId) {
    return _firestore
        .collection('cfqs')
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
      return followingUp.contains(userId);
    });
  }

  Future<void> _createFollowUpNotification(String cfqId) async {
    try {
      if (_currentUser == null) return;

      // Get the CFQ document to get the organizer's ID and following users
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> cfqData = cfqSnapshot.data() as Map<String, dynamic>;
      List<String> followingUsers =
          List<String>.from(cfqData['followingUp'] ?? []);

      // Remove current user from notification recipients
      followingUsers.remove(_currentUser!.uid);

      if (followingUsers.isEmpty) return;

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
          'followerId': _currentUser!.uid,
          'followerUsername': _currentUser!.username,
          'followerProfilePictureUrl': _currentUser!.profilePictureUrl,
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

        // Increment unread notifications count for the user
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

  Future<void> toggleFollowUp(String cfqId, String userId) async {
    try {
      final batch = _firestore.batch();
      final cfqRef = _firestore.collection('cfqs').doc(cfqId);

      final cfqDoc = await cfqRef.get();
      if (!cfqDoc.exists) {
        throw Exception('CFQ document does not exist');
      }

      final data = cfqDoc.data()!;
      String channelId = data['channelId'] as String;
      List<dynamic> followingUp = List<dynamic>.from(data['followingUp'] ?? []);

      bool isNowFollowing = !followingUp.contains(userId);

      if (isNowFollowing) {
        followingUp.add(userId);
        batch.update(cfqRef, {'followingUp': followingUp});
        await batch.commit();
        await _createFollowUpNotification(cfqId);
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
      } else {
        followingUp.remove(userId);
        batch.update(cfqRef, {'followingUp': followingUp});
        await batch.commit();
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
    }
  }

  Future<void> loadFavoriteEvents() async {
    try {
      QuerySnapshot favoritesSnapshot = await _firestore
          .collection('cfqs')
          .where(FieldPath.documentId, whereIn: currentUser!.favorites)
          .get();

      _favoriteEvents = favoritesSnapshot.docs;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading favorite events: $e');
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
      final batch = _firestore.batch();
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(_currentUser!.uid);

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

      attending.remove(_currentUser!.uid);
      notAttending.remove(_currentUser!.uid);
      notSureAttending.remove(_currentUser!.uid);

      // Add user to appropriate list only if not unselecting
      if (status != 'notAnswered') {
        switch (status) {
          case 'attending':
            attending.add(_currentUser!.uid);
            break;
          case 'notAttending':
            notAttending.add(_currentUser!.uid);
            break;
          case 'notSureAttending':
            notSureAttending.add(_currentUser!.uid);
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
        attendingStatus.remove(turnId);
      } else {
        attendingStatus[turnId] = status;
      }
      batch.update(userRef, {'attendingStatus': attendingStatus});

      await batch.commit();
      final organizerId = turnData['uid'] as String;

      // Create notification if attending
      if (status == 'attending' && organizerId != _currentUser!.uid) {
        await _createAttendingNotification(turnId);
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

  Stream<List<DocumentSnapshot>> fetchFavoriteEventsStream() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .switchMap((userSnap) {
      if (!userSnap.exists) {
        return Stream.value(<DocumentSnapshot>[]);
      }

      final userData = userSnap.data() as Map<String, dynamic>;
      final favorites = List<String>.from(userData['favorites'] ?? []);

      if (favorites.isEmpty) {
        return Stream.value(<DocumentSnapshot>[]);
      }

      Stream<Map<String, DocumentSnapshot>> cfqsStream = _firestore
          .collection('cfqs')
          .where(FieldPath.documentId, whereIn: favorites)
          .snapshots()
          .map((snapshot) => Map.fromEntries(snapshot.docs
              .where((doc) => !isEventExpired(doc))
              .map((doc) => MapEntry(doc.id, doc))));

      Stream<Map<String, DocumentSnapshot>> turnsStream = _firestore
          .collection('turns')
          .where(FieldPath.documentId, whereIn: favorites)
          .snapshots()
          .map((snapshot) => Map.fromEntries(snapshot.docs
              .where((doc) => !isEventExpired(doc))
              .map((doc) => MapEntry(doc.id, doc))));

      return Rx.combineLatest2(
        cfqsStream,
        turnsStream,
        (Map<String, DocumentSnapshot> cfqs,
            Map<String, DocumentSnapshot> turns) {
          Map<String, DocumentSnapshot> eventsMap = {...cfqs, ...turns};

          return favorites
              .map((id) => eventsMap[id])
              .where((doc) => doc != null)
              .cast<DocumentSnapshot>()
              .toList()
              .reversed
              .toList();
        },
      );
    });
  }

  bool isEventExpired(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isTurn = doc.reference.parent.id == 'turns';
    final DateTime now = DateTime.now();

    if (isTurn) {
      // Handle Turn expiration
      final DateTime? endDateTime =
          data['endDateTime'] != null ? parseDate(data['endDateTime']) : null;
      final DateTime eventDateTime = parseDate(data['eventDateTime']);

      if (endDateTime != null) {
        return now.isAfter(endDateTime.add(const Duration(hours: 12)));
      } else {
        return now.isAfter(eventDateTime.add(const Duration(hours: 24)));
      }
    } else {
      // Handle CFQ expiration
      final DateTime? endDateTime =
          data['endDateTime'] != null ? parseDate(data['endDateTime']) : null;
      final DateTime? eventDateTime = data['eventDateTime'] != null
          ? parseDate(data['eventDateTime'])
          : null;
      final DateTime publishedDateTime = parseDate(data['datePublished']);

      if (endDateTime != null) {
        return now.isAfter(endDateTime.add(const Duration(hours: 12)));
      } else if (eventDateTime != null) {
        return now.isAfter(eventDateTime.add(const Duration(hours: 24)));
      } else {
        return now.isAfter(publishedDateTime.add(const Duration(hours: 24)));
      }
    }
  }

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date as DateTime: $date");
        return DateTime.now();
      }
    } else if (date is DateTime) {
      return date;
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  Stream<List<DocumentSnapshot>> fetchFavoriteEvents() {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots()
          .switchMap((userSnapshot) {
        if (!userSnapshot.exists) {
          return Stream.value(<DocumentSnapshot>[]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final favorites = List<String>.from(userData['favorites'] ?? []);

        if (favorites.isEmpty) {
          return Stream.value(<DocumentSnapshot>[]);
        }

        // Split favorites into chunks of 30
        final cfqChunks = _chunkList(favorites, 30);

        // Create streams for each chunk
        final eventStreams = cfqChunks.map((chunk) => chunk.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: chunk)
                .snapshots()
                .map((snapshot) => snapshot.docs
                    .where((doc) => !isEventExpired(doc))
                    .toList()));

        // Combine all streams
        return Rx.combineLatest(eventStreams,
            (List<List<DocumentSnapshot>> results) {
          List<DocumentSnapshot> allEvents = results.expand((x) => x).toList();
          allEvents.sort((a, b) {
            DateTime dateA =
                parseDate((a.data() as Map<String, dynamic>)['eventDateTime']);
            DateTime dateB =
                parseDate((b.data() as Map<String, dynamic>)['eventDateTime']);
            return dateA.compareTo(dateB);
          });
          return allEvents;
        });
      });
    } catch (error) {
      AppLogger.error("Error in fetchFavoriteEvents: $error");
      return Stream.value([]);
    }
  }
}
