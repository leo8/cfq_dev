import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';

class ConversationsViewModel extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  final model.User currentUser;
  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  final TextEditingController searchController = TextEditingController();

  List<Conversation> get filteredConversations => _filteredConversations;

  ConversationsViewModel({required this.currentUser}) {
    AppLogger.debug(
        'ConversationsViewModel initialized for user: ${currentUser.uid}');
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    AppLogger.debug('Loading conversations for user: ${currentUser.uid}');
    _conversations =
        await _conversationService.getUserConversations(currentUser.uid);
    AppLogger.debug('Loaded ${_conversations.length} conversations');
    _sortConversations();
    _filteredConversations = _conversations;
    AppLogger.debug(
        'Filtered conversations set, count: ${_filteredConversations.length}');
    notifyListeners();
  }

  void _sortConversations() {
    _conversations.sort(
        (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    AppLogger.debug('Conversations sorted');
  }

  void searchConversations(String query) {
    AppLogger.debug('Searching conversations with query: $query');
    _filteredConversations = _conversations
        .where((conversation) =>
            conversation.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    AppLogger.debug('Search results: ${_filteredConversations.length}');
    notifyListeners();
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(
        currentUser.uid, channelId);
    await _loadConversations();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUser.uid, channelId);
    await _loadConversations();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
