import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String channelId, String message, String senderId) async {
    await _firestore
        .collection('conversations')
        .doc(channelId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': senderId,
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
}
