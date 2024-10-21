import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessageContent;
  final String lastSenderUsername;
  final DateTime lastMessageTimestamp;

  Conversation({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.lastMessageContent,
    required this.lastSenderUsername,
    required this.lastMessageTimestamp,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastSenderUsername: data['lastSenderUsername'] ?? '',
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp).toDate(),
    );
  }
}
