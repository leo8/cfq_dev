import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';
import '../utils/styles/string.dart';

class FriendsListViewModel extends ChangeNotifier {
  final String currentUserId;

  final TextEditingController searchController = TextEditingController();
  List<model.User> _allFriends = [];
  List<model.User> _filteredFriends = [];

  List<model.User> get friends => _filteredFriends;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<model.User> _friends = [];

  // Status variables for error handling and success messages
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _friendRemoved = false;
  bool get friendRemoved => _friendRemoved;

  FriendsListViewModel({required this.currentUserId}) {
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      // Fetch current user's data
      DocumentSnapshot currentUserSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      model.User currentUser = model.User.fromSnap(currentUserSnap);

      // Get friends UIDs
      List<dynamic> friendsUids = currentUser.friends;

      // If no friends, set _friends to empty and return
      if (friendsUids.isEmpty) {
        _friends = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch friends data
      List<model.User> friendsList = [];

      // Firestore 'in' query supports up to 10 items
      int batchSize = 10;
      for (int i = 0; i < friendsUids.length; i += batchSize) {
        List<dynamic> batch = friendsUids.sublist(
            i,
            i + batchSize > friendsUids.length
                ? friendsUids.length
                : i + batchSize);

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: batch)
            .get();

        List<model.User> batchUsers =
            snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();

        friendsList.addAll(batchUsers);
      }

      _friends = friendsList;
    } catch (e) {
      AppLogger.error('Error fetching friends: $e');
      _errorMessage = CustomString.failedToFetchFriends;
    }

    _allFriends = _friends;
    _filteredFriends = _allFriends;
    _isLoading = false;
    notifyListeners();
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      _filteredFriends = _allFriends;
    } else {
      _filteredFriends = _allFriends
          .where((friend) =>
              friend.username.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    try {
      // Get references to the user documents
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      DocumentReference friendRef =
          FirebaseFirestore.instance.collection('users').doc(friendId);

      // Update the friends lists atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove friend's ID from current user's friends list
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([friendId])
      });

      // Remove current user's ID from friend's friends list
      batch.update(friendRef, {
        'friends': FieldValue.arrayRemove([currentUserId])
      });

      // Commit the batch
      await batch.commit();

      // Remove friend from local list
      _friends.removeWhere((friend) => friend.uid == friendId);

      // Set friendRemoved to true
      _friendRemoved = true;

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error removing friend: $e');
      _errorMessage = CustomString.failedToRemoveFriend;
      notifyListeners();
    }
  }

  // Resets status variables after handling
  void resetStatus() {
    _friendRemoved = false;
    _errorMessage = null;
    // No need to call notifyListeners() here unless the UI depends on these variables
  }
}
