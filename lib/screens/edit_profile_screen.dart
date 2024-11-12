import 'package:flutter/material.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_edit_form.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const EditProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack, // Sets the background color
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.customBlack,
        surfaceTintColor: CustomColor.customBlack,
        actions: [
          IconButton(
            icon: CustomIcon.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
                  onSave:
                      (username, location, birthDate, newProfilePicture) async {
                    if (newProfilePicture != null) {
                      await viewModel.updateProfilePicture(newProfilePicture);
                    }
                    await viewModel.updateUserProfile(username, location,
                        birthDate); // Pop twice to go back to the profile screen
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
