import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../view_models/profile_view_model.dart';
import '../screens/edit_profile_screen.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';

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
            leading: const Icon(CustomIcon.editProfile),
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
            leading: const Icon(CustomIcon.confidentiality),
            title: const Text(CustomString.privacy),
            onTap: () {
              // Navigate to privacy settings screen
            },
          ),
          ListTile(
            leading: const Icon(CustomIcon.notificationsSettings),
            title: const Text(CustomString.notifications),
            onTap: () {
              // Navigate to notification settings screen
            },
          ),
          // Add more parameter options as needed
          const Divider(),
          ListTile(
            leading: const Icon(CustomIcon.logOut, color: CustomColor.red),
            title: Text(CustomString.logOut, style: CustomTextStyle.redtitle3),
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
