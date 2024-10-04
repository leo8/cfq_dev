import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_content.dart';
import '../screens/parameters_screen.dart';
import 'friends_list_screen.dart';

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
            // Existing status handling...

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.user == null) {
              return const Center(child: Text('User not found'));
            } else {
              return Center(
                child: ProfileContent(
                  user: viewModel.user!,
                  isFriend: viewModel.isFriend,
                  isCurrentUser: viewModel.isCurrentUser,
                  onActiveChanged: viewModel.isCurrentUser
                      ? (bool newValue) {
                          viewModel.updateIsActiveStatus(newValue);
                          viewModel.fetchUserData();
                        }
                      : null,
                  onFriendsTap: () async {
                    // Navigate to FriendsListScreen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendsListScreen(
                          currentUserId: viewModel.user!.uid,
                        ),
                      ),
                    );
                    // Refresh the profile data upon returning
                    viewModel.fetchUserData();
                  },
                  onParametersTap: viewModel.isCurrentUser
                    ? () {
                        // Navigate to the parameters screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParametersScreen(viewModel: viewModel),
                          ),
                        );
                      }
                    : null,
                  onLogoutTap:
                      viewModel.isCurrentUser ? () => viewModel.logOut() : null,
                  onAddFriendTap:
                      !viewModel.isCurrentUser && !viewModel.isFriend
                          ? () {
                              viewModel.addFriend(onSuccess: () {});
                            }
                          : null,
                  onRemoveFriendTap:
                      !viewModel.isCurrentUser && viewModel.isFriend
                          ? () {
                              viewModel.removeFriend(onSuccess: () {});
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
