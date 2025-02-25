import 'package:flutter/material.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_edit_form.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const EditProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack, // Sets the background color
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.customBlack,
        surfaceTintColor: CustomColor.customBlack,
        actions: [
          IconButton(
            icon: CustomIcon.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        title: Text(
          CustomString.myProfileCapital,
          style: CustomTextStyle.bigBody1,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileEditForm(
                  initialUsername: viewModel.user!.username,
                  initialLocation: viewModel.user!.location,
                  initialBirthDate: viewModel.user!.birthDate,
                  initialProfilePictureUrl: viewModel.user!.profilePictureUrl,
                  userNames: viewModel.userNames,
                  onSave:
                      (username, location, birthDate, newProfilePicture) async {
                    if (newProfilePicture != null) {
                      await viewModel.updateProfilePicture(newProfilePicture);
                    }
                    await viewModel.updateUserProfile(
                      username,
                      location,
                      birthDate,
                      newProfilePicture,
                    ); // Pop twice to go back to the profile screen
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
