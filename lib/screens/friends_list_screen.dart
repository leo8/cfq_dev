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
import '../widgets/molecules/custom_search_bar.dart';
import '../utils/styles/icons.dart';
import '../../utils/utils.dart';

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
          leading: IconButton(
            icon: CustomIcon.arrowBack,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
            Consumer<FriendsListViewModel>(
              builder: (context, viewModel, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () => viewModel
                        .performSearch(viewModel.searchController.text),
                    child: CustomSearchBar(
                      controller: viewModel.searchController,
                      hintText: CustomString.searchFriends,
                      onChanged: (value) => viewModel.performSearch(value),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
              child: Consumer<FriendsListViewModel>(
                builder: (context, viewModel, child) {
                  // Handle success and error messages
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (viewModel.friendRemoved) {
                      showSnackBar(CustomString.friendDeleted, context);
                      viewModel.resetStatus();
                    } else if (viewModel.errorMessage != null) {
                      showSnackBar(viewModel.errorMessage!, context);
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
                            const Divider(),
                            ListTile(
                              leading: ClickableAvatar(
                                userId: friend.uid,
                                imageUrl: friend.profilePictureUrl,
                                radius: 20,
                                isActive: friend.isActive,
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
