import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../utils/logger.dart';
import '../providers/conversation_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/notification.dart' as model;
import 'package:uuid/uuid.dart';

class FavoritesViewModel extends ChangeNotifier {
  final String currentUserId;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  model.User? _currentUser;
  List<DocumentSnapshot> _favoriteEvents = [];
  bool _isLoading = true;

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
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null || _currentUser!.favorites.isEmpty) {
        _favoriteEvents = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch both turns and cfqs
      Map<String, DocumentSnapshot> eventsMap = {};

      // Store fetched documents in map with their IDs
      (await FirebaseFirestore.instance
              .collection('turns')
              .where('turnId', whereIn: _currentUser!.favorites)
              .get())
          .docs
          .forEach((doc) => eventsMap[doc['turnId']] = doc);

      (await FirebaseFirestore.instance
              .collection('cfqs')
              .where('cfqId', whereIn: _currentUser!.favorites)
              .get())
          .docs
          .forEach((doc) => eventsMap[doc['cfqId']] = doc);

      // Reconstruct list in original order and reverse it
      _favoriteEvents = _currentUser!.favorites
          .map((id) => eventsMap[id])
          .where((doc) => doc != null)
          .cast<DocumentSnapshot<Object?>>()
          .toList()
          .reversed
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching favorite events: $e');
      _isLoading = false;
      notifyListeners();
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

      // Get the CFQ document to get the organizer's ID and name
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> cfqData = cfqSnapshot.data() as Map<String, dynamic>;
      String organizerId = cfqData['uid'] as String;
      String cfqName = cfqData['cfqName'] as String;

      // Get the organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(organizerId).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': model.NotificationType.followUp.toString().split('.').last,
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

      // Increment unread notifications count for the organizer
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating follow-up notification: $e');
    }
  }

  Future<void> toggleFollowUp(String cfqId, String userId) async {
    try {
      DocumentReference cfqRef = _firestore.collection('cfqs').doc(cfqId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot cfqSnapshot = await transaction.get(cfqRef);

        if (!cfqSnapshot.exists) {
          throw Exception('CFQ document does not exist');
        }

        Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
        List<dynamic> followingUp = data['followingUp'] ?? [];

        bool isNowFollowing = !followingUp.contains(userId);

        if (isNowFollowing) {
          followingUp.add(userId);
          // Create notification only when following up, not when unfollowing
          await _createFollowUpNotification(cfqId);
        } else {
          followingUp.remove(userId);
        }

        transaction.update(cfqRef, {'followingUp': followingUp});
      });

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

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(currentUserId);

      await _firestore.runTransaction((transaction) async {
        final turnDoc = await transaction.get(turnRef);
        final userDoc = await transaction.get(userRef);

        if (!turnDoc.exists || !userDoc.exists) {
          throw Exception('Turn or User document does not exist');
        }

        Map<String, dynamic> turnData = turnDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Remove user from all attending lists
        ['attending', 'notSureAttending', 'notAttending', 'notAnswered']
            .forEach((field) {
          if (turnData[field] != null) {
            turnData[field] = (turnData[field] as List)
                .where((id) => id != currentUserId)
                .toList();
          }
        });

        // Add user to the appropriate list
        if (status != 'notAnswered') {
          turnData[status] = [...(turnData[status] ?? []), currentUserId];
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

      // Fetch both turns and cfqs that are in favorites
      Stream<List<DocumentSnapshot>> cfqsStream = _firestore
          .collection('cfqs')
          .where(FieldPath.documentId, whereIn: favorites)
          .snapshots()
          .map((snapshot) => snapshot.docs);

      Stream<List<DocumentSnapshot>> turnsStream = _firestore
          .collection('turns')
          .where(FieldPath.documentId, whereIn: favorites)
          .snapshots()
          .map((snapshot) => snapshot.docs);

      return Rx.combineLatest2(
        cfqsStream,
        turnsStream,
        (List<DocumentSnapshot> cfqs, List<DocumentSnapshot> turns) {
          List<DocumentSnapshot> allEvents = [...cfqs, ...turns];
          allEvents.sort((a, b) {
            DateTime dateA =
                (a.data() as Map<String, dynamic>)['datePublished'].toDate();
            DateTime dateB =
                (b.data() as Map<String, dynamic>)['datePublished'].toDate();
            return dateB.compareTo(dateA);
          });
          return allEvents;
        },
      );
    });
  }
}
