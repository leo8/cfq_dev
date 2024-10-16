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
      backgroundColor: CustomColor.customBlack,
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: CustomColor.customBlack,
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Text(
              CustomString.parametersCapital,
              style: CustomTextStyle.body1.copyWith(fontSize: 28),
            ),
          ),
          const SizedBox(
            height: 70,
          ),
          const Divider(),
          ListTile(
            leading: CustomIcon.profile,
            title: Text(
              CustomString.editProfile,
              style: CustomTextStyle.body1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(viewModel: viewModel),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: CustomIcon.favorite,
            title: Text(
              CustomString.favorites,
              style: CustomTextStyle.body1,
            ),
            onTap: () {
              // Navigate to notification settings screen
            },
          ),
          // Add more parameter options as needed
          const Divider(),
          ListTile(
            leading: const Icon(CustomIcon.logOut, color: CustomColor.red),
            title: Text(
              CustomString.logOut,
              style: CustomTextStyle.body1.copyWith(color: CustomColor.red),
            ),
            onTap: () async {
              await viewModel.logOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
