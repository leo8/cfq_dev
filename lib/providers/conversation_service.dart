import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import 'package:rxdart/rxdart.dart';
import '../utils/logger.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> incrementUnreadMessages(
      String userId, String conversationId) async {
    final userDoc = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final conversations = (userData['conversations'] as List<dynamic>?)
              ?.map((e) =>
                  model.ConversationInfo.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [];

      final conversationIndex =
          conversations.indexWhere((c) => c.conversationId == conversationId);
      if (conversationIndex != -1) {
        conversations[conversationIndex].unreadMessagesCount++;
      } else {
        conversations.add(model.ConversationInfo(
            conversationId: conversationId, unreadMessagesCount: 1));
      }

      transaction.update(userDoc,
          {'conversations': conversations.map((e) => e.toMap()).toList()});
    });
  }

  Future<void> resetUnreadMessages(String userId, String conversationId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          List<Map<String, dynamic>> conversations =
              List<Map<String, dynamic>>.from(userData['conversations'] ?? []);

          int index = conversations
              .indexWhere((conv) => conv['conversationId'] == conversationId);
          if (index != -1) {
            conversations[index]['unreadMessagesCount'] = 0;
            transaction.update(userRef, {'conversations': conversations});
          }
        }
      });
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String channelId, String message, String senderId,
      String senderUsername, String senderProfilePicture) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Step 1: Perform all reads
        DocumentReference conversationRef =
            _firestore.collection('conversations').doc(channelId);
        DocumentSnapshot conversationSnapshot =
            await transaction.get(conversationRef);

        if (!conversationSnapshot.exists) {
          throw Exception('Conversation does not exist');
        }

        Map<String, dynamic> conversationData =
            conversationSnapshot.data() as Map<String, dynamic>;
        List<String> members = List<String>.from(conversationData['members']);

        Map<String, DocumentSnapshot> userSnapshots = {};
        for (String memberId in members) {
          if (memberId != senderId) {
            DocumentReference userRef =
                _firestore.collection('users').doc(memberId);
            DocumentSnapshot userSnapshot = await transaction.get(userRef);
            if (userSnapshot.exists) {
              userSnapshots[memberId] = userSnapshot;
            } else {
              AppLogger.warning('User document not found for member $memberId');
            }
          }
        }

        // Step 2: Perform all writes
        // Add the new message
        DocumentReference messageRef =
            conversationRef.collection('messages').doc();
        transaction.set(messageRef, {
          'message': message,
          'senderId': senderId,
          'senderUsername': senderUsername,
          'senderProfilePicture': senderProfilePicture,
          'timestamp': FieldValue.serverTimestamp(),
        });

        AppLogger.info('New message added to conversation: $channelId');

        // Update conversation details
        transaction.update(conversationRef, {
          'lastMessageContent': message,
          'lastSenderUsername': senderUsername,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });

        AppLogger.info(
            'Conversation $channelId updated with new message details');

        for (String memberId in userSnapshots.keys) {
          DocumentSnapshot userSnapshot = userSnapshots[memberId]!;

          // Update unreadMessagesCount
          List<Map<String, dynamic>> conversations =
              List<Map<String, dynamic>>.from(
                  userSnapshot['conversations'] ?? []);

          int index = conversations
              .indexWhere((conv) => conv['conversationId'] == channelId);
          if (index != -1) {
            conversations[index]['unreadMessagesCount'] =
                (conversations[index]['unreadMessagesCount'] ?? 0) + 1;
            transaction.update(
                userSnapshot.reference, {'conversations': conversations});
            AppLogger.info(
                'Incremented unreadMessagesCount for user $memberId in conversation $channelId');
          } else {
            AppLogger.warning(
                'Conversation $channelId not found in user $memberId\'s list. Skipping unreadMessagesCount update.');
          }
        }
      });

      AppLogger.info('Message sent successfully to conversation: $channelId');
    } catch (e) {
      AppLogger.error('Error sending message to conversation $channelId: $e');
      rethrow;
    }
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
    try {
      // First get the user's conversation IDs
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      List<dynamic> conversationInfos =
          (userDoc.data() as Map<String, dynamic>)['conversations'] ?? [];
      List<String> conversationIds = conversationInfos
          .map((info) =>
              (info as Map<String, dynamic>)['conversationId'] as String)
          .toList();

      // If no conversations, return empty list
      if (conversationIds.isEmpty) {
        return [];
      }

      // Split conversation IDs into chunks of 30
      List<List<String>> chunks = [];
      for (var i = 0; i < conversationIds.length; i += 30) {
        chunks.add(
          conversationIds.sublist(
            i,
            i + 30 > conversationIds.length ? conversationIds.length : i + 30,
          ),
        );
      }

      // Fetch conversations in chunks
      List<Conversation> allConversations = [];
      for (var chunk in chunks) {
        QuerySnapshot conversationsSnapshot = await FirebaseFirestore.instance
            .collection('conversations')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        List<Conversation> chunkConversations = conversationsSnapshot.docs
            .map((doc) => Conversation.fromSnap(doc))
            .toList();

        allConversations.addAll(chunkConversations);
      }

      return allConversations;
    } catch (e) {
      AppLogger.error('Error fetching user conversations: $e');
      rethrow;
    }
  }

  Future<void> createConversation(
    String channelId,
    String eventName,
    String eventPicture,
    List<String> members,
    String organizerId,
    String organizerName,
    String organizerProfilePicture,
  ) async {
    // Ensure the organizer is in the members list
    if (!members.contains(organizerId)) {
      members.add(organizerId);
    }

    await _firestore.collection('conversations').doc(channelId).set({
      'name': eventName,
      'imageUrl': eventPicture,
      'members': members,
      'organizerName': organizerName,
      'organizerProfilePicture': organizerProfilePicture,
      'lastMessageContent': '',
      'lastSenderUsername': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
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
    await _firestore.runTransaction((transaction) async {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        List<model.ConversationInfo> conversations = (userData['conversations']
                    as List<dynamic>?)
                ?.map((e) =>
                    model.ConversationInfo.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

        if (!conversations.any((conv) => conv.conversationId == channelId)) {
          conversations.add(model.ConversationInfo(
              conversationId: channelId, unreadMessagesCount: 0));
          transaction.update(userRef, {
            'conversations': conversations.map((e) => e.toMap()).toList(),
          });
        }
      }
    });
  }

  Future<void> removeConversationFromUser(
      String userId, String channelId) async {
    await _firestore.runTransaction((transaction) async {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        List<model.ConversationInfo> conversations = (userData['conversations']
                    as List<dynamic>?)
                ?.map((e) =>
                    model.ConversationInfo.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

        conversations.removeWhere((conv) => conv.conversationId == channelId);
        transaction.update(userRef, {
          'conversations': conversations.map((e) => e.toMap()).toList(),
        });
      }
    });
  }

  Stream<List<Conversation>> getUserConversationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .switchMap((userDoc) {
      if (!userDoc.exists || userDoc.data() == null) {
        return Stream.value([]);
      }

      List<model.ConversationInfo> conversationInfos =
          (userDoc.data()!['conversations'] as List<dynamic>?)
                  ?.map((e) =>
                      model.ConversationInfo.fromMap(e as Map<String, dynamic>))
                  .toList() ??
              [];

      List<String> conversationIds =
          conversationInfos.map((info) => info.conversationId).toList();

      if (conversationIds.isEmpty) {
        return Stream.value([]);
      }

      // Split conversationIds into chunks of 30 or less
      List<List<String>> chunks = [];
      for (var i = 0; i < conversationIds.length; i += 30) {
        chunks.add(
          conversationIds.sublist(
            i,
            i + 30 > conversationIds.length ? conversationIds.length : i + 30,
          ),
        );
      }

      // Create a stream for each chunk
      List<Stream<List<Conversation>>> chunkStreams = chunks.map((chunk) {
        return _firestore
            .collection('conversations')
            .where(FieldPath.documentId, whereIn: chunk)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Conversation.fromFirestore(doc))
                .toList());
      }).toList();

      // Combine all chunk streams
      return Rx.combineLatestList(chunkStreams).map((chunkedResults) {
        List<Conversation> allConversations = chunkedResults
            .expand((e) => e)
            .toList()
          ..sort((a, b) =>
              b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
        return allConversations;
      });
    });
  }

  Future<bool> isConversationInUserList(String userId, String channelId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    List<dynamic> conversations = userDoc['conversations'] ?? [];
    return conversations.any((conv) => conv['conversationId'] == channelId);
  }
}
