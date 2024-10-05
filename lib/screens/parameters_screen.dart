import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../view_models/profile_view_model.dart';

class ParametersScreen extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback? onLogoutTap;

  const ParametersScreen({
    Key? key,
    required this.viewModel,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parameters'),
        backgroundColor: CustomColor.mobileBackgroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              // Navigate to edit profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy Settings'),
            onTap: () {
              // Navigate to privacy settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            onTap: () {
              // Navigate to notification settings screen
            },
          ),
          // Add more parameter options as needed
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await viewModel.logOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}