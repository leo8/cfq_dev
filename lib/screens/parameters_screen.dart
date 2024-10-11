import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../view_models/profile_view_model.dart';
import '../screens/edit_profile_screen.dart';

class ParametersScreen extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback? onLogoutTap;

  const ParametersScreen({
    super.key,
    required this.viewModel,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomString.parameters),
        backgroundColor: CustomColor.mobileBackgroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(CustomString.editProfile),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(viewModel: viewModel),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text(CustomString.privacy),
            onTap: () {
              // Navigate to privacy settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text(CustomString.notifications),
            onTap: () {
              // Navigate to notification settings screen
            },
          ),
          // Add more parameter options as needed
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              CustomString.logOut,
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await viewModel.logOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
