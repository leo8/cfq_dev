import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../utils/logger.dart';
import '../models/notification.dart' as notificationModel;
import '../models/user.dart' as model;
import 'package:uuid/uuid.dart';

class RequestsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId;

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  RequestsViewModel({required this.currentUserId}) {
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        _currentUser = model.User.fromSnap(userDoc);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error initializing current user: $e');
    }
  }

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

        // Create notification for requester
        await createAcceptedTeamRequestNotification(
          requesterId: request.requesterId,
          teamId: request.teamId ?? '',
          teamName: request.teamName ?? '',
          teamImageUrl: request.teamImageUrl ?? '',
        );
      } else if (request.type == RequestType.friend) {
        // Add requester to current user's friends list
        batch.update(_firestore.collection('users').doc(currentUserId), {
          'friends': FieldValue.arrayUnion([request.requesterId])
        });

        // Add current user to requester's friends list
        batch.update(_firestore.collection('users').doc(request.requesterId), {
          'friends': FieldValue.arrayUnion([currentUserId])
        });

        // Create notification for requester
        await createAcceptedFriendRequestNotification(
          requesterId: request.requesterId,
        );

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
      AppLogger.debug('Denying request: $requestId');

      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final user = User.fromSnap(userDoc);
      final request = user.requests.firstWhere((r) => r.id == requestId);

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Remove request from current user's requests
      final updatedRequests =
          user.requests.where((r) => r.id != requestId).toList();
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'requests': updatedRequests.map((r) => r.toJson()).toList(),
      });

      // Remove request from requester's requests
      if (request.type == RequestType.friend) {
        final requesterDoc =
            await _firestore.collection('users').doc(request.requesterId).get();
        final requesterUser = User.fromSnap(requesterDoc);
        final updatedRequesterRequests =
            requesterUser.requests.where((r) => r.id != requestId).toList();

        batch.update(_firestore.collection('users').doc(request.requesterId), {
          'requests': updatedRequesterRequests.map((r) => r.toJson()).toList(),
        });
      }

      // Commit the batch
      await batch.commit();
      AppLogger.debug('Request denied and removed successfully');

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error denying request: $e');
      rethrow;
    }
  }

  Future<void> createAcceptedTeamRequestNotification({
    required String requesterId,
    required String teamId,
    required String teamName,
    required String teamImageUrl,
  }) async {
    try {
      if (_currentUser == null) return;

      // Get the requester's notification channel ID
      DocumentSnapshot requesterDoc =
          await _firestore.collection('users').doc(requesterId).get();
      String requesterNotificationChannelId = (requesterDoc.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.acceptedTeamRequest
            .toString()
            .split('.')
            .last,
        'content': {
          'teamId': teamId,
          'teamName': teamName,
          'teamImageUrl': teamImageUrl,
          'accepterId': _currentUser!.uid,
          'accepterUsername': _currentUser!.username,
          'accepterProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification
      await _firestore
          .collection('notifications')
          .doc(requesterNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count
      await _firestore.collection('users').doc(requesterId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating accepted team request notification: $e');
    }
  }

  Future<void> createAcceptedFriendRequestNotification({
    required String requesterId,
  }) async {
    try {
      if (_currentUser == null) return;

      // Get the requester's notification channel ID
      DocumentSnapshot requesterDoc =
          await _firestore.collection('users').doc(requesterId).get();
      String requesterNotificationChannelId = (requesterDoc.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.acceptedFriendRequest
            .toString()
            .split('.')
            .last,
        'content': {
          'accepterId': _currentUser!.uid,
          'accepterUsername': _currentUser!.username,
          'accepterProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification
      await _firestore
          .collection('notifications')
          .doc(requesterNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count
      await _firestore.collection('users').doc(requesterId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error(
          'Error creating accepted friend request notification: $e');
    }
  }
}
