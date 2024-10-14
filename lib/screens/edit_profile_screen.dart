import 'package:flutter/material.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_edit_form.dart';
import '../templates/auth_template.dart';
import '../../utils/styles/icons.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const EditProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ProfileEditForm(
                      initialUsername: viewModel.user!.username,
                      initialLocation: viewModel.user!.location,
                      initialBirthDate: viewModel.user!.birthDate,
                      initialProfilePictureUrl:
                          viewModel.user!.profilePictureUrl,
                      onSave: (username, location, birthDate,
                          newProfilePicture) async {
                        if (newProfilePicture != null) {
                          await viewModel
                              .updateProfilePicture(newProfilePicture);
                        }
                        await viewModel.updateUserProfile(username, location,
                            birthDate); // Pop twice to go back to the profile screen
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: CustomIcon.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
