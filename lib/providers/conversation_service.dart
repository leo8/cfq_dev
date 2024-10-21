import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import 'package:rxdart/rxdart.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String channelId, String message, String senderId,
      String senderUsername, String senderProfilePicture) async {
    await _firestore.runTransaction((transaction) async {
      // Add the message to the messages subcollection
      DocumentReference messageRef = _firestore
          .collection('conversations')
          .doc(channelId)
          .collection('messages')
          .doc();

      transaction.set(messageRef, {
        'message': message,
        'senderId': senderId,
        'senderUsername': senderUsername,
        'senderProfilePicture': senderProfilePicture,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the conversation document
      DocumentReference conversationRef =
          _firestore.collection('conversations').doc(channelId);
      transaction.update(conversationRef, {
        'lastMessageContent': message,
        'lastSenderUsername': senderUsername,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
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
    String channelId,
    String eventName,
    String eventPicture,
    List<String> members,
    String organizerName,
    String organizerProfilePicture,
  ) async {
    await _firestore.collection('conversations').doc(channelId).set({
      'name': eventName,
      'imageUrl': eventPicture,
      'lastMessage': '',
      'lastSenderUsername': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'members': members,
      'organizerName': organizerName,
      'organizerProfilePicture': organizerProfilePicture,
      'searchKey': eventName.toLowerCase(),
    }, SetOptions(merge: true));
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

  Stream<List<Conversation>> getUserConversationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .switchMap((userDoc) {
      List<String> conversationIds =
          List<String>.from(userDoc.data()?['conversations'] ?? []);

      if (conversationIds.isEmpty) {
        return Stream.value([]);
      }

      return _firestore
          .collection('conversations')
          .where(FieldPath.documentId, whereIn: conversationIds)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList()
          ..sort((a, b) =>
              b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
      });
    });
  }
}
