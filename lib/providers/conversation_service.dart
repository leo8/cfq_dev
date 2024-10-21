import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String channelId, String message, String senderId,
      String senderUsername, String senderProfilePicture) async {
    await _firestore
        .collection('conversations')
        .doc(channelId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderProfilePicture': senderProfilePicture,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String channelId) {
    return _firestore
        .collection('conversations')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<model.User>> getInviteeDetails(List inviteeIds) async {
    List<model.User> invitees = [];
    for (String id in inviteeIds) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userDoc.exists) {
        invitees.add(model.User.fromSnap(userDoc));
      }
    }
    return invitees;
  }

  Future<List<Conversation>> getUserConversations(String userId) async {
    List<Conversation> conversations = [];

    // Fetch the user document to get the list of conversation IDs
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    List<String> conversationIds =
        List<String>.from(userDoc['conversations'] ?? []);

    // Fetch each conversation
    for (String channelId in conversationIds) {
      DocumentSnapshot conversationDoc =
          await _firestore.collection('conversations').doc(channelId).get();
      if (conversationDoc.exists) {
        conversations.add(Conversation.fromFirestore(conversationDoc));
      }
    }

    return conversations;
  }

  Future<void> createConversation(
      String channelId, String name, String imageUrl) async {
    await _firestore.collection('conversations').doc(channelId).set({
      'name': name,
      'imageUrl': imageUrl,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateConversationLastMessage(String channelId,
      String lastMessageContent, String lastSenderUsername) async {
    await _firestore.collection('conversations').doc(channelId).update({
      'lastMessageContent': lastMessageContent,
      'lastSenderUsername': lastSenderUsername,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addConversationToUser(String userId, String channelId) async {
    await _firestore.collection('users').doc(userId).update({
      'conversations': FieldValue.arrayUnion([channelId])
    });
  }

  Future<void> removeConversationFromUser(
      String userId, String channelId) async {
    await _firestore.collection('users').doc(userId).update({
      'conversations': FieldValue.arrayRemove([channelId])
    });
  }
}
