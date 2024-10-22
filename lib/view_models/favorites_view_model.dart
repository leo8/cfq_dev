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
}
