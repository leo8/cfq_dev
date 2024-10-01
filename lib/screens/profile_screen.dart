import 'package:cfq_dev/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/profile_template.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/auth_methods.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/profile_content.dart';

/// ProfileScreen allows users to view their profile information and update status.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  model.User? _user; // Holds the user data
  bool _isLoading = true; // Tracks if the profile data is still loading

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen is initialized
  }

  /// Fetches the logged-in user's details from Firestore.
  Future<void> fetchUserData() async {
    try {
      model.User userData = await AuthMethods().getUserDetails();
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppLogger.error(e.toString());
    }
  }

  /// Logs out the current user.
  void logOut(BuildContext context) async {
    await AuthMethods().logOutUser();
  }

  /// Updates the user's active status in the Firestore.
  void updateIsActiveStatus(bool isActive) async {
    try {
      await AuthMethods().updateIsActiveStatus(isActive);
    } catch (e) {
      AppLogger.error(e.toString());
      // Revert the change in the UI if the update fails
      setState(() {
        if (_user != null) {
          _user!.isActive = !isActive;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(CustomString.failedtoUpdateStatusPleaseTryAgain),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProfileTemplate(
              backgroundImageUrl:
                  'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              body: ProfileContent(
                user: _user!,
                onActiveChanged: (bool newValue) {
                  // Update user's active status when the switch is toggled
                  setState(() {
                    _user!.isActive = newValue;
                  });
                  updateIsActiveStatus(newValue);
                },
                onFollowersTap: () {
                  // Handle followers tap
                },
                onFollowingTap: () {
                  // Handle following tap
                },
                onLogoutTap: () => logOut(context), // Handle logout
              ),
            ),
    );
  }
}
