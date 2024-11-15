import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../view_models/profile_view_model.dart';
import '../screens/edit_profile_screen.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
import '../screens/favorites_screen.dart';
import '../view_models/requests_view_model.dart';
import '../screens/requests_screen.dart';

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
        surfaceTintColor: CustomColor.customBlack,
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              CustomString.parametersCapital,
              style: CustomTextStyle.body1
                  .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 25,
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
            leading: CustomIcon.saved,
            title: Text(
              CustomString.favorites,
              style: CustomTextStyle.body1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                      currentUserId: viewModel.currentUser!.uid),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: CustomIcon.addMember,
            title: Text(
              CustomString.requests,
              style: CustomTextStyle.body1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestsScreen(
                    viewModel: RequestsViewModel(
                      currentUserId: viewModel.currentUser!.uid,
                    ),
                  ),
                ),
              );
            },
          ),
          // Add more parameter options as needed
          const Divider(),
          ListTile(
            leading: const Icon(CustomIcon.logOut, color: CustomColor.red),
            title: Text(
              CustomString.logOut,
              style: CustomTextStyle.body1Bold.copyWith(color: CustomColor.red),
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
