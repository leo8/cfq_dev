import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../providers/user_provider.dart';

class ExpandedCardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String eventId;
  final String currentUserId;
  final bool isTurn;

  bool _isFavorite = false;
  bool _isFollowingUp = false;
  int _followersCount = 0;

  ExpandedCardViewModel({
    required this.eventId,
    required this.currentUserId,
    required this.isTurn,
  }) {
    _initializeData();
  }

  bool get isFavorite => _isFavorite;
  bool get isFollowingUp => _isFollowingUp;
  int get followersCount => _followersCount;

  Future<void> _initializeData() async {
    await _fetchFavoriteStatus();
    if (isTurn) {
      await _fetchFollowUpStatus();
      await _fetchFollowersCount();
    } else {
      await _fetchFollowUpStatus();
      await _fetchFollowersCount();
    }
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      List<dynamic> favorites =
          (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
      _isFavorite = favorites.contains(eventId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching favorite status: $e');
    }
  }

  Future<void> _fetchFollowUpStatus() async {
    try {
      DocumentSnapshot cfqDoc =
          await _firestore.collection('cfqs').doc(eventId).get();
      List<dynamic> followingUp =
          (cfqDoc.data() as Map<String, dynamic>)['followingUp'] ?? [];
      _isFollowingUp = followingUp.contains(currentUserId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching follow-up status: $e');
    }
  }

  Future<void> _fetchFollowersCount() async {
    try {
      DocumentSnapshot cfqDoc =
          await _firestore.collection('cfqs').doc(eventId).get();
      List<dynamic> followingUp =
          (cfqDoc.data() as Map<String, dynamic>)['followingUp'] ?? [];
      _followersCount = followingUp.length;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching followers count: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);

      // Update Firestore
      if (_isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([eventId])
        });
      }

      // Update local state
      _isFavorite = !_isFavorite;
      notifyListeners();

      // Add this line to update UserProvider
      UserProvider().refreshUser();
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
    }
  }

  Stream<int> get attendingCountStream {
    if (!isTurn) return Stream.value(0);

    return _firestore
        .collection('turns')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['attending'] as List?)?.length ?? 0;
    });
  }

  Stream<String> get attendingStatusStream {
    if (!isTurn) return Stream.value('notAnswered');

    return _firestore
        .collection('turns')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 'notAnswered';
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['attending']?.contains(currentUserId) ?? false)
        return 'attending';
      if (data['notSureAttending']?.contains(currentUserId) ?? false)
        return 'notSureAttending';
      if (data['notAttending']?.contains(currentUserId) ?? false)
        return 'notAttending';
      return 'notAnswered';
    });
  }

  Future<void> updateAttendingStatus(String status) async {
    if (!isTurn) return;

    try {
      final turnRef = _firestore.collection('turns').doc(eventId);
      final userRef = _firestore.collection('users').doc(currentUserId);

      await _firestore.runTransaction((transaction) async {
        final turnDoc = await transaction.get(turnRef);
        final userDoc = await transaction.get(userRef);

        if (!turnDoc.exists || !userDoc.exists) {
          throw Exception('Turn or User document does not exist');
        }

        Map<String, dynamic> turnData = turnDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Remove user from all attending lists
        ['attending', 'notSureAttending', 'notAttending'].forEach((field) {
          if (turnData[field] != null) {
            turnData[field] = (turnData[field] as List)
                .where((id) => id != currentUserId)
                .toList();
          }
        });

        // Add user to the appropriate list
        if (status != 'notAnswered') {
          turnData[status] = [...(turnData[status] ?? []), currentUserId];
        }

        // Update user's attending status for this turn
        if (userData['attendingStatus'] == null) {
          userData['attendingStatus'] = {};
        }
        userData['attendingStatus'][eventId] = status;

        transaction.update(turnRef, turnData);
        transaction.update(userRef, userData);
      });

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating attending status: $e');
    }
  }

  Stream<bool> get isFollowingUpStream {
    if (!isTurn) {
      return _firestore
          .collection('cfqs')
          .doc(eventId)
          .snapshots()
          .map((snapshot) {
        List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
        return followingUp.contains(currentUserId);
      });
    }
    return Stream.value(false);
  }

  Future<void> toggleFollowUp() async {
    if (isTurn) return; // Only proceed for CFQ cards

    try {
      final cfqRef = _firestore.collection('cfqs').doc(eventId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot cfqSnapshot = await transaction.get(cfqRef);

        if (!cfqSnapshot.exists) {
          throw Exception('CFQ document does not exist');
        }

        Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
        List<String> followingUp = List<String>.from(data['followingUp'] ?? []);

        if (followingUp.contains(currentUserId)) {
          followingUp.remove(currentUserId);
        } else {
          followingUp.add(currentUserId);
        }

        transaction.update(cfqRef, {'followingUp': followingUp});
      });

      // We don't need to update local state or call notifyListeners() here
      // because the stream will automatically update the UI
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
    }
  }

  Stream<DocumentSnapshot> get cfqStream {
    return _firestore.collection('cfqs').doc(eventId).snapshots();
  }
}
