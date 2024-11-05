import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart';

// Provider class that manages the current user's data and state
class UserProvider with ChangeNotifier {
  User? _user; // Private variable to hold the current user's information
  final AuthMethods _authMethods =
      AuthMethods(); // Instance of AuthMethods to fetch user data
  bool _isInitialized = false;

  // New getter to check initialization status
  bool get isInitialized => _isInitialized;

  // Safe getter that returns null if user isn't loaded
  User? get user => _user;

  // Initialize user data
  Future<void> initialize() async {
    if (!_isInitialized) {
      await refreshUser();
      _isInitialized = true;
    }
  }

  // Refresh the current user's data by fetching the latest details from Firebase
  Future<void> refreshUser() async {
    try {
      User user =
          await _authMethods.getUserDetails(); // Fetch updated user details
      _user = user; // Update the _user variable with the fetched data
      notifyListeners(); // Notify listeners (UI components) that the user data has changed
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      _user = null;
      notifyListeners();
    }
  }

  // Clear user data (useful for logout)
  void clearUser() {
    _user = null;
    _isInitialized = false;
    notifyListeners();
  }
}
