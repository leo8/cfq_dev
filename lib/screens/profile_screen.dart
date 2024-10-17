import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/organisms/profile_content.dart';
import '../screens/parameters_screen.dart';
import 'friends_list_screen.dart';
import '../../utils/styles/icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;

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
                  icon: CustomIcon.arrowBack,
                  color: CustomColor.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                return const SizedBox.shrink(); // No back button
              }
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.user == null) {
              return const Center(child: Text(CustomString.userNotFound));
            } else {
              return StreamBuilder<DocumentSnapshot>(
                stream: viewModel.userStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: ProfileContent(
                        user: model.User.fromSnap(snapshot.data!),
                        isFriend: viewModel.isFriend,
                        isCurrentUser: viewModel.isCurrentUser,
                        onActiveChanged: viewModel.isCurrentUser
                            ? (bool newValue) {
                                viewModel.updateIsActiveStatus(newValue);
                              }
                            : null,
                        onFriendsTap: viewModel.isCurrentUser
                            ? () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsListScreen(
                                      currentUserId: viewModel.user!.uid,
                                    ),
                                  ),
                                );
                                viewModel.fetchUserData();
                              }
                            : null,
                        onParametersTap: viewModel.isCurrentUser
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ParametersScreen(
                                        viewModel: viewModel,
                                        onLogoutTap: () => viewModel.logOut()),
                                  ),
                                );
                              }
                            : null,
                        onLogoutTap: viewModel.isCurrentUser
                            ? () => viewModel.logOut()
                            : null,
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
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
