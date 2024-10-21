import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;

class ConversationsViewModel extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  final model.User currentUser;
  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  final TextEditingController searchController = TextEditingController();

  List<Conversation> get filteredConversations => _filteredConversations;

  ConversationsViewModel({required this.currentUser}) {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    _conversations =
        await _conversationService.getUserConversations(currentUser.uid);
    _sortConversations();
    _filteredConversations = _conversations;
    notifyListeners();
  }

  void _sortConversations() {
    _conversations.sort(
        (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
  }

  void searchConversations(String query) {
    _filteredConversations = _conversations
        .where((conversation) =>
            conversation.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(
        currentUser.uid, channelId);
    await _loadConversations();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
