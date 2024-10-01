import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

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

      // Determine if the profile user is a friend
      if (!_isCurrentUser) {
        _isFriend = _currentUser!.friends.contains(profileUserId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLogger.error(e.toString());
    }
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
}
