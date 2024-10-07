import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/view_models/thread_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../widgets/organisms/turn_card_content.dart';
import '../models/user.dart' as model;
import '../widgets/organisms/thread_header.dart';
import '../widgets/organisms/active_friends_list.dart';

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
          backgroundColor: CustomColor.mobileBackgroundColor,
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
              // Display search results (keep existing code)
              return _buildSearchResults(context, viewModel);
            } else {
              // Display the regular content
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
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user.profilePictureUrl),
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
          child: _buildEventsList(context, viewModel),
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

  Widget _buildEventsList(BuildContext context, ThreadViewModel viewModel) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: viewModel.fetchCombinedEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          AppLogger.error("Error fetching events: ${snapshot.error}");
          return const Center(child: Text(CustomString.errorFetchingEvents));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;

        if (events.isEmpty) {
          return const Center(child: Text(CustomString.noEventsAvailable));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isTurn = event.reference.parent.id == 'turns';

            if (isTurn) {
              return TurnCardContent(
                profilePictureUrl:
                    event['profilePictureUrl'] ?? CustomString.emptyString,
                username: event['username'] ?? CustomString.emptyString,
                organizers: List<String>.from(event['organizers'] ?? []),
                timeInfo: 'une heure', // Placeholder for time info
                turnName: event['turnName'] ?? CustomString.emptyString,
                description: event['description'] ?? CustomString.emptyString,
                eventDateTime: viewModel.parseDate(event['eventDateTime']),
                where: event['where'] ?? CustomString.emptyString,
                address: event['address'] ?? CustomString.emptyString,
                onAttendingPressed: () {
                  // Add attending functionality
                },
                onSharePressed: () {
                  // Add share functionality
                },
                onSendPressed: () {
                  // Add send functionality
                },
                onCommentPressed: () {
                  // Add comment functionality
                },
              );
            } else {
              return CFQCardContent(
                profilePictureUrl:
                    event['profilePictureUrl'] ?? CustomString.emptyString,
                username: event['username'] ?? CustomString.emptyString,
                organizers: List<String>.from(event['organizers'] ?? []),
                cfqName: event['cfqName'] ?? CustomString.emptyString,
                description: event['description'] ?? CustomString.emptyString,
                datePublished: viewModel.parseDate(event['datePublished']),
                location: event['where'] ?? CustomString.emptyString,
                onFollowPressed: () {
                  // Add follow functionality
                },
                onSharePressed: () {
                  // Add share functionality
                },
                onSendPressed: () {
                  // Add send functionality
                },
                onCommentPressed: () {
                  // Add comment functionality
                },
              );
            }
          },
        );
      },
    );
  }
}
