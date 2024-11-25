import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessageContent;
  final String lastSenderUsername;
  final DateTime lastMessageTimestamp;
  final List<String> members;
  final String organizerName;
  final String organizerId;
  final String organizerProfilePicture;
  final String searchKey;

  Conversation({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.lastMessageContent,
    required this.lastSenderUsername,
    required this.lastMessageTimestamp,
    required this.members,
    required this.organizerId,
    required this.organizerName,
    required this.organizerProfilePicture,
    required this.searchKey,
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
      members: List<String>.from(data['members'] ?? []),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerProfilePicture: data['organizerProfilePicture'] ?? '',
      searchKey: data['searchKey'] ?? data['name'].toLowerCase(),
    );
  }

  factory Conversation.fromSnap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastSenderUsername: data['lastSenderUsername'] ?? '',
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerProfilePicture: data['organizerProfilePicture'] ?? '',
      searchKey: data['searchKey'] ?? data['name'].toLowerCase(),
    );
  }
}
