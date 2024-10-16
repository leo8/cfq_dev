import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/view_models/thread_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../models/user.dart' as model;
import '../widgets/organisms/thread_header.dart';
import '../widgets/organisms/active_friends_list.dart';
import '../widgets/organisms/events_list.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).getUser;

    return ChangeNotifierProvider<ThreadViewModel>(
      create: (_) => ThreadViewModel(currentUserUid: currentUser.uid),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: CustomColor.customBlack,
          elevation: 0,
          title: Consumer<ThreadViewModel>(
            builder: (context, viewModel, child) {
              return ThreadHeader(
                searchController: viewModel.searchController,
                onNotificationTap: () {
                  // Add notification functionality later
                },
                onMessageTap: () {
                  // Add message functionality later
                },
              );
            },
          ),
        ),
        body: Consumer<ThreadViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.searchController.text.isNotEmpty) {
              return _buildSearchResults(context, viewModel);
            } else {
              return _buildRegularContent(context, viewModel);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ThreadViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.users.isEmpty) {
      return const Center(
        child: CustomText(
          text: CustomString.noUsersFound,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: viewModel.users.length,
        itemBuilder: (context, index) {
          model.User user = viewModel.users[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: user.uid),
                ),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: CustomColor.white24,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: user.isActive
                          ? [
                              const BoxShadow(
                                color: CustomColor.turnColor,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(user.profilePictureUrl),
                    ),
                  ),
                  const SizedBox(width: 16),
                  CustomText(
                    text: user.username,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildRegularContent(BuildContext context, ThreadViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 135),
        _buildActiveFriendsList(context, viewModel),
        const SizedBox(height: 20),
        Expanded(
          child: EventsList(eventsStream: viewModel.fetchCombinedEvents()),
        ),
      ],
    );
  }

  Widget _buildActiveFriendsList(
      BuildContext context, ThreadViewModel viewModel) {
    return ActiveFriendsList(
      currentUser: viewModel.currentUser!,
      activeFriends: viewModel.activeFriends,
      onActiveChanged: (bool newValue) {
        viewModel.updateIsActiveStatus(newValue);
      },
      onFriendTap: (String friendId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: friendId),
          ),
        );
      },
    );
  }
}
