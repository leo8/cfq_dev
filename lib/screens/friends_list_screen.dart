import 'package:cfq_dev/utils/styles/string.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:cfq_dev/utils/styles/text_styles.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as model;
import 'package:provider/provider.dart';
import '../view_models/friends_list_view_model.dart';
import 'profile_screen.dart';
import '../widgets/atoms/avatars/clickable_avatar.dart';
import '../widgets/atoms/buttons/custom_button.dart';

class FriendsListScreen extends StatelessWidget {
  final String currentUserId;

  const FriendsListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FriendsListViewModel>(
      create: (_) => FriendsListViewModel(currentUserId: currentUserId),
      child: Scaffold(
        backgroundColor: CustomColor.customBlack,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: CustomColor.customBlack,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                CustomString.myFriendsCapital,
                style: CustomTextStyle.body1
                    .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            Expanded(
              child: Consumer<FriendsListViewModel>(
                builder: (context, viewModel, child) {
                  // Handle success and error messages
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (viewModel.friendRemoved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(CustomString.friendDeleted)),
                      );
                      viewModel.resetStatus();
                    } else if (viewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(viewModel.errorMessage!)),
                      );
                      viewModel.resetStatus();
                    }
                  });

                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (viewModel.friends.isEmpty) {
                    return const Center(
                      child: Text(CustomString.noFriendsYet),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: viewModel.friends.length,
                      itemBuilder: (context, index) {
                        model.User friend = viewModel.friends[index];
                        return Column(
                          children: [
                            Divider(),
                            ListTile(
                              leading: ClickableAvatar(
                                userId: friend.uid,
                                imageUrl: friend.profilePictureUrl,
                                radius: 20, // Adjust as needed
                                onTap: () {
                                  // Navigate to friend's profile
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileScreen(userId: friend.uid),
                                    ),
                                  );
                                },
                              ),
                              title: Text(friend.username),
                              trailing: CustomButton(
                                  label: CustomString.removeFriend,
                                  textStyle: CustomTextStyle.subButton
                                      .copyWith(fontWeight: FontWeight.bold),
                                  onTap: () {
                                    viewModel.removeFriend(friend.uid);
                                  },
                                  color: CustomColor.customBlack,
                                  borderWidth: 0.5,
                                  borderRadius: 5,
                                  width: 110,
                                  height: 50),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
