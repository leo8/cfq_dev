import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/profile_template.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/auth_methods.dart';

import '../utils/styles/string.dart';
import '../widgets/organisms/profile_content.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  model.User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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
      print(e.toString());
    }
  }

  void logOut(BuildContext context) async {
    await AuthMethods().logOutUser();
  }

  void updateIsActiveStatus(bool isActive) async {
    try {
      await AuthMethods().updateIsActiveStatus(isActive);
    } catch (e) {
      print(e.toString());
      // Revert the change in the UI
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
                onLogoutTap: () => logOut(context),
              ),
            ),
    );
  }
}
