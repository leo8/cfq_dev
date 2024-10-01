import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/profile_template.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:provider/provider.dart';
import '../utils/styles/string.dart';
import '../utils/styles/colors.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_content.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(userId: userId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColor.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              // Show back button if viewing another user's profile
              if (!viewModel.isCurrentUser) {
                return IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                return SizedBox.shrink(); // No back button
              }
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            // Check if friend was added or removed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.friendAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(CustomString.amiAjoute),
                  ),
                );
                viewModel.resetStatus();
              } else if (viewModel.friendRemoved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(CustomString.amiSupprime),
                  ),
                );
                viewModel.resetStatus();
              }
            });

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.user == null) {
              return const Center(child: Text('User not found'));
            } else {
              return ProfileTemplate(
                backgroundImageUrl:
                    'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop',
                body: ProfileContent(
                  user: viewModel.user!,
                  isFriend: viewModel.isFriend,
                  isCurrentUser: viewModel.isCurrentUser,
                  onActiveChanged: viewModel.isCurrentUser
                      ? (bool newValue) {
                          viewModel.updateIsActiveStatus(newValue);
                        }
                      : null,
                  onFriendsTap: () {
                    // Handle friends tap
                  },
                  onLogoutTap:
                      viewModel.isCurrentUser ? () => viewModel.logOut() : null,
                  onAddFriendTap:
                      !viewModel.isCurrentUser && !viewModel.isFriend
                          ? () {
                              viewModel.addFriend(onSuccess: () {
                                // Success handled in the ViewModel
                              });
                            }
                          : null,
                  onRemoveFriendTap:
                      !viewModel.isCurrentUser && viewModel.isFriend
                          ? () {
                              viewModel.removeFriend(onSuccess: () {
                                // Success handled in the ViewModel
                              });
                            }
                          : null,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
