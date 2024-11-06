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

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update request status to accepted for current user
      final updatedRequests = user.requests.map((r) {
        if (r.id == requestId) {
          return Request(
            id: r.id,
            type: r.type,
            requesterId: r.requesterId,
            requesterUsername: r.requesterUsername,
            requesterProfilePictureUrl: r.requesterProfilePictureUrl,
            teamId: r.teamId,
            teamName: r.teamName,
            teamImageUrl: r.teamImageUrl,
            timestamp: r.timestamp,
            status: RequestStatus.accepted,
          );
        }
        return r;
      }).toList();

      batch.update(_firestore.collection('users').doc(currentUserId), {
        'requests': updatedRequests.map((r) => r.toJson()).toList(),
      });

      if (request.type == RequestType.team) {
        // Add user to team members
        batch.update(_firestore.collection('teams').doc(request.teamId), {
          'members': FieldValue.arrayUnion([currentUserId])
        });

        // Add team to user's teams
        batch.update(_firestore.collection('users').doc(currentUserId), {
          'teams': FieldValue.arrayUnion([request.teamId])
        });
      } else if (request.type == RequestType.friend) {
        // Add requester to current user's friends list
        batch.update(_firestore.collection('users').doc(currentUserId), {
          'friends': FieldValue.arrayUnion([request.requesterId])
        });

        // Add current user to requester's friends list
        batch.update(_firestore.collection('users').doc(request.requesterId), {
          'friends': FieldValue.arrayUnion([currentUserId])
        });

        // Update request status for requester
        final requesterDoc =
            await _firestore.collection('users').doc(request.requesterId).get();

        if (requesterDoc.exists) {
          final requesterUser = User.fromSnap(requesterDoc);
          final updatedRequesterRequests = requesterUser.requests.map((r) {
            if (r.id == requestId) {
              return Request(
                id: r.id,
                type: r.type,
                requesterId: r.requesterId,
                requesterUsername: r.requesterUsername,
                requesterProfilePictureUrl: r.requesterProfilePictureUrl,
                teamId: r.teamId,
                teamName: r.teamName,
                teamImageUrl: r.teamImageUrl,
                timestamp: r.timestamp,
                status: RequestStatus.accepted,
              );
            }
            return r;
          }).toList();

          batch
              .update(_firestore.collection('users').doc(request.requesterId), {
            'requests':
                updatedRequesterRequests.map((r) => r.toJson()).toList(),
          });
        }
      }

      // Commit the batch
      await batch.commit();
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

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update request status to denied for current user
      final updatedRequests = user.requests.map((r) {
        if (r.id == requestId) {
          return Request(
            id: r.id,
            type: r.type,
            requesterId: r.requesterId,
            requesterUsername: r.requesterUsername,
            requesterProfilePictureUrl: r.requesterProfilePictureUrl,
            teamId: r.teamId,
            teamName: r.teamName,
            teamImageUrl: r.teamImageUrl,
            timestamp: r.timestamp,
            status: RequestStatus.denied,
          );
        }
        return r;
      }).toList();

      batch.update(_firestore.collection('users').doc(currentUserId), {
        'requests': updatedRequests.map((r) => r.toJson()).toList(),
      });

      // If it's a friend request, update the request status for the requester as well
      if (request.type == RequestType.friend) {
        final requesterDoc =
            await _firestore.collection('users').doc(request.requesterId).get();

        if (requesterDoc.exists) {
          final requesterUser = User.fromSnap(requesterDoc);
          final updatedRequesterRequests = requesterUser.requests.map((r) {
            if (r.id == requestId) {
              return Request(
                id: r.id,
                type: r.type,
                requesterId: r.requesterId,
                requesterUsername: r.requesterUsername,
                requesterProfilePictureUrl: r.requesterProfilePictureUrl,
                teamId: r.teamId,
                teamName: r.teamName,
                teamImageUrl: r.teamImageUrl,
                timestamp: r.timestamp,
                status: RequestStatus.denied,
              );
            }
            return r;
          }).toList();

          batch
              .update(_firestore.collection('users').doc(request.requesterId), {
            'requests':
                updatedRequesterRequests.map((r) => r.toJson()).toList(),
          });
        }
      }

      // Commit the batch
      await batch.commit();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error denying request: $e');
      rethrow;
    }
  }
}
