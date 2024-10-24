import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart';

// Provider class that manages the current user's data and state
class UserProvider with ChangeNotifier {
  User? _user; // Private variable to hold the current user's information
  final AuthMethods _authMethods =
      AuthMethods(); // Instance of AuthMethods to fetch user data

  // Getter to access the current user. Using '!' to assert that _user is non-null
  User? get getUser => _user;

  // Refresh the current user's data by fetching the latest details from Firebase
  Future<void> refreshUser() async {
    User user =
        await _authMethods.getUserDetails(); // Fetch updated user details
    _user = user; // Update the _user variable with the fetched data
    notifyListeners(); // Notify listeners (UI components) that the user data has changed
  }
}
