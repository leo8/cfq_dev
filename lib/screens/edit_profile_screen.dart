import 'package:flutter/material.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_edit_form.dart';
import '../utils/styles/colors.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const EditProfileScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile'),
        backgroundColor: CustomColor.mobileBackgroundColor,
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return ProfileEditForm(
            initialUsername: viewModel.user!.username,
            initialEmail: viewModel.user!.email,
            initialBio: viewModel.user!.bio,
            onSave: (username, email, bio) async {
              await viewModel.updateUserProfile(username, email, bio);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}