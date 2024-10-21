import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;

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
}
