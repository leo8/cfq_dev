import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class RequestsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId;

  RequestsViewModel({required this.currentUserId});

  Stream<List<Request>> get pendingRequestsStream {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      final user = User.fromSnap(snapshot);
      return user.requests
          .where((request) => request.status == RequestStatus.pending)
          .toList();
    });
  }

  Future<void> acceptRequest(String requestId) async {
    // Implementation for accepting request
  }

  Future<void> denyRequest(String requestId) async {
    // Implementation for denying request
  }
}
