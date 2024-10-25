import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../providers/storage_methods.dart';
import 'dart:typed_data';

class ProfileViewModel extends ChangeNotifier {
  final String? userId;
  model.User? _user; // Profile user's data
  model.User? _currentUser; // Current user's data
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  model.User? get user => _user;
  bool _isCurrentUser = false;
  bool get isCurrentUser => _isCurrentUser;
  bool _isFriend = false; // Indicates if the profile user is a friend
  bool get isFriend => _isFriend;

  // Status variables for UI feedback
  bool _friendAdded = false;
  bool get friendAdded => _friendAdded;

  model.User? get currentUser => _currentUser;

  bool _friendRemoved = false;
  bool get friendRemoved => _friendRemoved;

  Stream<DocumentSnapshot>? _userStream;
  Stream<DocumentSnapshot>? get userStream => _userStream;

  int _commonFriendsCount = 0;
  int get commonFriendsCount => _commonFriendsCount;

  int _commonTeamsCount = 0;
  int get commonTeamsCount => _commonTeamsCount;

  ProfileViewModel({this.userId}) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get current user's UID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Determine which user profile to display
      String profileUserId = userId ?? currentUserId;

      // Fetch profile user's data
      model.User userData =
          await AuthMethods().getUserDetailsById(profileUserId);

      // Fetch current user's data if viewing another user's profile
      if (profileUserId != currentUserId) {
        _currentUser = await AuthMethods().getUserDetailsById(currentUserId);
      } else {
        _currentUser = userData; // Viewing own profile
      }

      _user = userData;
      _isCurrentUser = (profileUserId == currentUserId);

      if (!_isCurrentUser) {
        _isFriend = _currentUser!.friends.contains(profileUserId);

        // Calculate common friends
        _commonFriendsCount = _currentUser!.friends
            .where((friendId) => _user!.friends.contains(friendId))
            .length;

        // Calculate common teams
        _commonTeamsCount = _currentUser!.teams
            .where((teamId) => _user!.teams.contains(teamId))
            .length;
      }

      _isLoading = false;
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(profileUserId)
          .snapshots();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLogger.error(e.toString());
    }
  }

  /// Adds the profile user as a friend
  Future<void> addFriend({required VoidCallback onSuccess}) async {
    if (_isCurrentUser || _isFriend) return;

    try {
      // Get references to the user documents
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      DocumentReference viewedUserRef =
          FirebaseFirestore.instance.collection('users').doc(_user!.uid);

      // Update the friends lists atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add viewed user's ID to current user's friends list
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([_user!.uid])
      });

      // Add current user's ID to viewed user's friends list
      batch.update(viewedUserRef, {
        'friends': FieldValue.arrayUnion([_currentUser!.uid])
      });

      // Commit the batch
      await batch.commit();

      // Update the local model.User objects
      _currentUser!.friends.add(_user!.uid);
      _user!.friends.add(_currentUser!.uid);

      // Update isFriend status
      _isFriend = true;

      // Set friendAdded to true
      _friendAdded = true;

      notifyListeners();

      // Call the success callback
      onSuccess();
    } catch (e) {
      AppLogger.error('Error adding friend: $e');
      // Optionally, handle the error
    }
  }

  /// Removes the profile user from friends
  Future<void> removeFriend({required VoidCallback onSuccess}) async {
    if (_isCurrentUser || !_isFriend) return;

    try {
      // Get references to the user documents
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      DocumentReference viewedUserRef =
          FirebaseFirestore.instance.collection('users').doc(_user!.uid);

      // Update the friends lists atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove viewed user's ID from current user's friends list
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([_user!.uid])
      });

      // Remove current user's ID from viewed user's friends list
      batch.update(viewedUserRef, {
        'friends': FieldValue.arrayRemove([_currentUser!.uid])
      });

      // Commit the batch
      await batch.commit();

      // Update the local model.User objects
      _currentUser!.friends.remove(_user!.uid);
      _user!.friends.remove(_currentUser!.uid);

      // Update isFriend status
      _isFriend = false;

      // Set friendRemoved to true
      _friendRemoved = true;

      notifyListeners();

      // Call the success callback
      onSuccess();
    } catch (e) {
      AppLogger.error('Error removing friend: $e');
      // Optionally, handle the error
    }
  }

  // Reset the status variables after the UI has displayed the message
  void resetStatus() {
    _friendAdded = false;
    _friendRemoved = false;
    notifyListeners();
  }

  /// Updates the user's active status in Firestore.
  Future<void> updateIsActiveStatus(bool isActive) async {
    if (!_isCurrentUser) return;
    try {
      await AuthMethods().updateIsActiveStatus(isActive);
      _user!.isActive = isActive;
      notifyListeners();
    } catch (e) {
      AppLogger.error(e.toString());
    }
  }

  /// Logs out the current user.
  Future<void> logOut() async {
    if (!_isCurrentUser) return;
    await AuthMethods().logOutUser();
  }

  Future<void> updateUserProfile(
      String username, String location, DateTime? birthDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'username': username,
        'location': location,
        'birthDate': birthDate?.toIso8601String(),
      });

      // Update local user object
      _user = model.User(
        username: username,
        email: _user!.email,
        uid: _user!.uid,
        friends: _user!.friends,
        teams: _user!.teams,
        profilePictureUrl: _user!.profilePictureUrl,
        location: location,
        birthDate: birthDate,
        isActive: _user!.isActive,
        searchKey: username.toLowerCase(),
        postedTurns: _user!.postedTurns,
        invitedTurns: _user!.invitedTurns,
        postedCfqs: _user!.postedCfqs,
        invitedCfqs: _user!.invitedCfqs,
        favorites: _user!.favorites,
        conversations: _user!.conversations,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error(e.toString());
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture(Uint8List file) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload new profile picture to storage
      String profilePictureUrl = await StorageMethods()
          .uploadImageToStorage('profilePicture', file, false);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'profilePictureUrl': profilePictureUrl,
      });

      // Update local user object
      _user = model.User(
        username: _user!.username,
        email: _user!.email,
        uid: _user!.uid,
        friends: _user!.friends,
        teams: _user!.teams,
        profilePictureUrl: profilePictureUrl,
        location: _user!.location,
        birthDate: _user!.birthDate,
        isActive: _user!.isActive,
        searchKey: _user!.username.toLowerCase(),
        postedTurns: _user!.postedTurns,
        invitedTurns: _user!.invitedTurns,
        postedCfqs: _user!.postedCfqs,
        invitedCfqs: _user!.invitedCfqs,
        favorites: _user!.favorites,
        conversations: _user!.conversations,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error(e.toString());
      notifyListeners();
    }
  }
}
