import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../utils/logger.dart';

class RequestsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId;

  RequestsViewModel({required this.currentUserId});

  Stream<List<Request>> get requestsStream {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      final user = User.fromSnap(snapshot);
      final sortedRequests = user.requests
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sortedRequests;
    });
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final user = User.fromSnap(userDoc);
      final request = user.requests.firstWhere((r) => r.id == requestId);

      // Remove old request
      await _firestore.collection('users').doc(currentUserId).update({
        'requests': FieldValue.arrayRemove([request.toJson()]),
      });

      // Create updated request
      final updatedRequest = Request(
        id: request.id,
        type: request.type,
        requesterId: request.requesterId,
        requesterUsername: request.requesterUsername,
        requesterProfilePictureUrl: request.requesterProfilePictureUrl,
        teamId: request.teamId,
        teamName: request.teamName,
        teamImageUrl: request.teamImageUrl,
        timestamp: request.timestamp,
        status: RequestStatus.accepted,
      );

      // Add updated request
      await _firestore.collection('users').doc(currentUserId).update({
        'requests': FieldValue.arrayUnion([updatedRequest.toJson()]),
      });

      if (request.type == RequestType.team) {
        // Update team members
        await _firestore.collection('teams').doc(request.teamId).update({
          'members': FieldValue.arrayUnion([currentUserId])
        });

        // Update user's teams
        await _firestore.collection('users').doc(currentUserId).update({
          'teams': FieldValue.arrayUnion([request.teamId])
        });
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error accepting request: $e');
      rethrow;
    }
  }

  Future<void> denyRequest(String requestId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final user = User.fromSnap(userDoc);
      final request = user.requests.firstWhere((r) => r.id == requestId);

      // Remove old request
      await _firestore.collection('users').doc(currentUserId).update({
        'requests': FieldValue.arrayRemove([request.toJson()]),
      });

      // Create updated request
      final updatedRequest = Request(
        id: request.id,
        type: request.type,
        requesterId: request.requesterId,
        requesterUsername: request.requesterUsername,
        requesterProfilePictureUrl: request.requesterProfilePictureUrl,
        teamId: request.teamId,
        teamName: request.teamName,
        teamImageUrl: request.teamImageUrl,
        timestamp: request.timestamp,
        status: RequestStatus.denied,
      );

      // Add updated request
      await _firestore.collection('users').doc(currentUserId).update({
        'requests': FieldValue.arrayUnion([updatedRequest.toJson()]),
      });

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error denying request: $e');
      rethrow;
    }
  }
}
