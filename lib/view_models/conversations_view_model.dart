import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import 'dart:async';
import '../utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationsViewModel extends ChangeNotifier {
  final model.User currentUser;
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _allConversations = [];
  List<Conversation> _filteredConversations = [];
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ConversationsViewModel({required this.currentUser}) {
    initConversations();
    _listenToUserChanges();
  }

  List<Conversation> get conversations => _filteredConversations;

  void initConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = conversationsStream.listen(
      (updatedConversations) {
        _allConversations = updatedConversations;
        _filteredConversations = _allConversations;
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('ConversationsViewModel: Error in stream: $error');
      },
    );
  }

  void _listenToUserChanges() {
    _userSubscription = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final updatedConversations = (userData['conversations']
                    as List<dynamic>?)
                ?.map((e) =>
                    model.ConversationInfo.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

        currentUser.conversations.clear();
        currentUser.conversations.addAll(updatedConversations);

        notifyListeners();
      }
    });
  }

  void searchConversations(String query) {
    if (query.isEmpty) {
      _filteredConversations = _allConversations;
    } else {
      _filteredConversations = _allConversations
          .where((conversation) =>
              conversation.searchKey.contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(
        currentUser.uid, channelId);
    initConversations();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUser.uid, channelId);
    initConversations();
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _userSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Stream<List<Conversation>> get conversationsStream =>
      _conversationService.getUserConversationsStream(currentUser.uid);

  Future<void> incrementUnreadMessages(String conversationId) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .update({'unreadMessagesCount': FieldValue.increment(1)});
    notifyListeners();
  }

  Future<void> resetUnreadMessages(String conversationId) async {
    try {
      await _conversationService.resetUnreadMessages(
          currentUser.uid, conversationId);
      // Update the local state
      int index = currentUser.conversations
          .indexWhere((conv) => conv.conversationId == conversationId);
      if (index != -1) {
        currentUser.conversations[index].unreadMessagesCount = 0;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
    }
  }

  int getUnreadMessagesCount(String conversationId) {
    final conversationInfo = currentUser.conversations.firstWhere(
      (conv) => conv.conversationId == conversationId,
      orElse: () => model.ConversationInfo(
          conversationId: conversationId, unreadMessagesCount: 0),
    );
    return conversationInfo.unreadMessagesCount;
  }
}
