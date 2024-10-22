import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../utils/logger.dart';
import '../providers/conversation_service.dart';

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

      List<DocumentSnapshot> turns = await FirebaseFirestore.instance
          .collection('turns')
          .where('turnId', whereIn: _currentUser!.favorites)
          .get()
          .then((snapshot) => snapshot.docs);

      List<DocumentSnapshot> cfqs = await FirebaseFirestore.instance
          .collection('cfqs')
          .where('cfqId', whereIn: _currentUser!.favorites)
          .get()
          .then((snapshot) => snapshot.docs);

      _favoriteEvents = [...turns, ...cfqs];
      _favoriteEvents.sort((a, b) {
        DateTime dateA = (a['eventDateTime'] ?? a['datePublished']).toDate();
        DateTime dateB = (b['eventDateTime'] ?? b['datePublished']).toDate();
        return dateB.compareTo(dateA);
      });

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
      print('Error adding follow-up: $e');
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
      print('Error removing follow-up: $e');
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

  Future<void> toggleFollowUp(String documentId, String userId) async {
    try {
      DocumentReference cfqRef = _firestore.collection('cfqs').doc(documentId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot cfqSnapshot = await transaction.get(cfqRef);

        if (!cfqSnapshot.exists) {
          throw Exception('CFQ document does not exist');
        }

        Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
        List<dynamic> followingUp = data['followingUp'] ?? [];

        if (followingUp.contains(userId)) {
          followingUp.remove(userId);
        } else {
          followingUp.add(userId);
        }

        transaction.update(cfqRef, {'followingUp': followingUp});
      });

      // Update the local state
      await loadFavoriteEvents(); // Reload favorite events to reflect changes

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
}
