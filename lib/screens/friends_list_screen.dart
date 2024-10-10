import 'package:cfq_dev/utils/styles/string.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as model;
import 'package:provider/provider.dart';
import '../view_models/friends_list_view_model.dart';
import 'profile_screen.dart';
import '../widgets/atoms/avatars/clickable_avatar.dart';

class FriendsListScreen extends StatelessWidget {
  final String currentUserId;

  const FriendsListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FriendsListViewModel>(
      create: (_) => FriendsListViewModel(currentUserId: currentUserId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(CustomString.mesAmis),
        ),
        body: Consumer<FriendsListViewModel>(
          builder: (context, viewModel, child) {
            // Handle success and error messages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.friendRemoved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(CustomString.amiSupprime)),
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
                child: Text(CustomString.vousnAvezPasEncoredAmis),
              );
            } else {
              return ListView.builder(
                itemCount: viewModel.friends.length,
                itemBuilder: (context, index) {
                  model.User friend = viewModel.friends[index];
                  return ListTile(
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
                    trailing: ElevatedButton(
                      onPressed: () {
                        viewModel.removeFriend(friend.uid);
                      },
                      child: const Text(CustomString.retirer),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
