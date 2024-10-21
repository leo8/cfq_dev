import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import 'dart:async';
import '../utils/logger.dart';

class ConversationsViewModel extends ChangeNotifier {
  final model.User currentUser;
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<Conversation>>? _conversationsSubscription;

  ConversationsViewModel({required this.currentUser}) {
    initConversations();
  }

  void initConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = conversationsStream.listen(
      (updatedConversations) {
        _conversations = updatedConversations;
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('ConversationsViewModel: Error in stream: $error');
      },
    );
  }

  void searchConversations(String query) {
    // Implement search logic here
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
