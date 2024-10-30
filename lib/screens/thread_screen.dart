import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/view_models/thread_view_model.dart';
import 'package:cfq_dev/view_models/conversations_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../models/user.dart' as model;
import '../widgets/organisms/thread_header.dart';
import '../widgets/organisms/active_friends_list.dart';
import '../widgets/organisms/events_list.dart';
import 'conversations_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_screen.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Check if user is initialized
        if (!userProvider.isInitialized) {
          // Initialize user data if not already done
          userProvider.initialize();
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user exists
        final currentUser = userProvider.user;
        if (currentUser == null) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to load user data'),
            ),
          );
        }

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
                    onSearchTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchScreen(viewModel: viewModel),
                        ),
                      );
                    },
                    onNotificationTap: () {
                      // Add notification functionality later
                    },
                    onMessageTap: () {
                      _navigateToConversationsScreen(
                          context, viewModel.currentUser!);
                    },
                    unreadConversationsCountStream:
                        viewModel.unreadConversationsCountStream,
                  );
                },
              ),
            ),
            body: Consumer<ThreadViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isInitializing) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildRegularContent(context, viewModel);
              },
            ),
          ),
        );
      },
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
              viewModel.clearSearchString();
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: CustomColor.transparent,
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: 135), // Adjust this value as needed
        ),
        SliverToBoxAdapter(
          child: _buildActiveFriendsList(context, viewModel),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
        SliverToBoxAdapter(
          child: EventsList(
            eventsStream: viewModel.fetchCombinedEvents(),
            currentUser: viewModel.currentUser,
            onFavoriteToggle: (eventId, isFavorite) {
              viewModel.toggleFavorite(eventId, isFavorite);
            },
            addConversationToUserList: viewModel.addConversationToUserList,
            removeConversationFromUserList:
                viewModel.removeConversationFromUserList,
            isConversationInUserList: viewModel.isConversationInUserList,
            resetUnreadMessages: viewModel.resetUnreadMessages,
            addFollowUp: ThreadViewModel.addFollowUp,
            removeFollowUp: ThreadViewModel.removeFollowUp,
            isFollowingUpStream: viewModel.isFollowingUpStream,
            toggleFollowUp: viewModel.toggleFollowUp,
            onAttendingStatusChanged: viewModel.updateAttendingStatus,
            attendingStatusStream: viewModel.attendingStatusStream,
            attendingCountStream: viewModel.attendingCountStream,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFriendsList(
      BuildContext context, ThreadViewModel viewModel) {
    return StreamBuilder<DocumentSnapshot>(
      stream: viewModel.currentUserStream,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final currentUser = model.User.fromSnap(userSnapshot.data!);

        return StreamBuilder<List<model.User>>(
          stream: viewModel.activeFriendsStream,
          builder: (context, friendsSnapshot) {
            if (!friendsSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return ActiveFriendsList(
              currentUser: currentUser,
              activeFriends: friendsSnapshot.data!,
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
          },
        );
      },
    );
  }

  void _navigateToConversationsScreen(
      BuildContext context, model.User currentUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ConversationsViewModel(currentUser: currentUser),
          child: ConversationsScreen(currentUser: currentUser),
        ),
      ),
    );
  }
}
