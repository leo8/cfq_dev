import 'package:cfq_dev/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/ressources/auth_methods.dart';
import 'package:cfq_dev/models/user.dart' as model;

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
            content: Text(CustomString.failedtoUpdateStatusPleaseTryAgain)),
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
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture
                    CircleAvatar(
                      radius: 64,
                      backgroundImage:
                          NetworkImage(_user?.profilePictureUrl ?? CustomString.emptyString),
                    ),
                    const SizedBox(height: 20),
                    // Active Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          CustomString.off,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Switch(
                          value: _user?.isActive ?? false,
                          onChanged: (bool newValue) {
                            setState(() {
                              if (_user != null) {
                                _user!.isActive = newValue; // Updated line
                              }
                            });
                            // Update isActive in the database
                            updateIsActiveStatus(newValue);
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.white70,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        const Text(
                          CustomString.turn,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Username
                    Text(
                      _user?.username ?? CustomString.emptyString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Bio
                    Text(
                      _user?.bio ?? CustomString.emptyString,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Followers and Following
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Followers
                        GestureDetector(
                          onTap: () {
                            // Handle followers tap
                          },
                          child: Column(
                            children: [
                              Text(
                                '${_user?.followers.length ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Followers',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40), // Spacing between
                        // Following
                        GestureDetector(
                          onTap: () {
                            // Handle following tap
                          },
                          child: Column(
                            children: [
                              Text(
                                '${_user?.following.length ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Following',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Log out button
                    InkWell(
                      onTap: () => logOut(context),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7A00FF), Color(0xFF7900F4)],
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
