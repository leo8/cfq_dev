import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import 'dart:async';
import '../utils/logger.dart';

class ConversationsViewModel extends ChangeNotifier {
  final model.User currentUser;
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _allConversations = [];
  List<Conversation> _filteredConversations = [];
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<Conversation>>? _conversationsSubscription;

  ConversationsViewModel({required this.currentUser}) {
    initConversations();
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
    searchController.dispose();
    super.dispose();
  }

  Stream<List<Conversation>> get conversationsStream =>
      _conversationService.getUserConversationsStream(currentUser.uid);
}
