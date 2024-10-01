// profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/profile_template.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:provider/provider.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/profile_content.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(userId: userId),
      child: Scaffold(
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.user == null) {
              return const Center(child: Text('User not found'));
            } else {
              return ProfileTemplate(
                backgroundImageUrl:
                    'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                body: ProfileContent(
                  user: viewModel.user!,
                  onActiveChanged: viewModel.isCurrentUser
                      ? (bool newValue) {
                          viewModel.updateIsActiveStatus(newValue);
                        }
                      : null, // No active status switch for other users
                  onFollowersTap: () {
                    // Handle followers tap
                  },
                  onFollowingTap: () {
                    // Handle following tap
                  },
                  onLogoutTap: viewModel.isCurrentUser
                      ? () => viewModel.logOut()
                      : null, // No logout button for other users
                  onAddFriendTap: !viewModel.isCurrentUser
                      ? () {
                          // Handle add friend tap (currently does nothing)
                        }
                      : null, // Show 'Ajouter' button for other users
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
