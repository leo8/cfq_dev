import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../view_models/profile_view_model.dart';
import '../screens/edit_profile_screen.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
//import '../screens/favorites_screen.dart';
import '../view_models/requests_view_model.dart';
import '../screens/requests_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/login/login_screen_phone.dart';

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
        toolbarHeight: 60,
        backgroundColor: CustomColor.customBlack,
        surfaceTintColor: CustomColor.customBlack,
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          CustomString.myAccountCapital,
          style: CustomTextStyle.bigBody1,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            leading: CustomIcon.profile,
            title: Text(
              CustomString.myProfile,
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
          /*
          ListTile(
            leading: CustomIcon.saveEmpty,
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
          */
          ListTile(
            leading: CustomIcon.addMember,
            title: Text(
              CustomString.requests,
              style: CustomTextStyle.body1,
            ),
            trailing: StreamBuilder<int>(
              stream: viewModel.pendingRequestsCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: CustomColor.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      snapshot.data!.toString(),
                      style: CustomTextStyle.body2.copyWith(
                        color: CustomColor.customWhite,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
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
          const Divider(),
          ListTile(
            leading: CustomIcon.tutorial,
            title: Text(
              CustomString.tutorial,
              style: CustomTextStyle.body1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TutorialScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(CustomIcon.logOut, color: CustomColor.red),
            title: Text(
              CustomString.logOut,
              style: CustomTextStyle.body1Bold.copyWith(color: CustomColor.red),
            ),
            onTap: () async {
              await viewModel.logOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreenMobile(),
                ),
                (route) => false,
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
