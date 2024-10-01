import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/view_models/thread_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../widgets/molecules/custom_search_bar.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../widgets/organisms/turn_card_content.dart';
import '../models/user.dart' as model;

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user from UserProvider
    final currentUser = Provider.of<UserProvider>(context).getUser;

    return ChangeNotifierProvider<ThreadViewModel>(
      create: (_) => ThreadViewModel(currentUserUid: currentUser.uid),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: CustomColor.transparent,
          elevation: 0,
          title: Consumer<ThreadViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: CustomSearchBar(
                      controller: viewModel.searchController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Notification bell icon
                  IconButton(
                    icon: const Icon(
                      CustomIcon.notifications,
                      color: CustomColor.white,
                    ),
                    onPressed: () {
                      // Add functionality later
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: Consumer<ThreadViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.searchController.text.isNotEmpty) {
              // Display search results
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (viewModel.users.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: 'No users found.',
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: viewModel.users.length,
                  itemBuilder: (context, index) {
                    model.User user = viewModel.users[index];
                    return GestureDetector(
                      onTap: () {
                        // Handle tap (e.g., navigate to user profile)
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: CustomColor.white24,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            // Profile image
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  NetworkImage(user.profilePictureUrl),
                            ),
                            const SizedBox(width: 16),
                            // Username
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
            } else {
              // Display the regular content
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 135),
                    // Horizontal list of profile pictures (if needed)
                    // ... Existing code ...
                    const SizedBox(height: 20),
                    // Event list area
                    Expanded(
                      child: StreamBuilder<List<DocumentSnapshot>>(
                        stream: viewModel.fetchCombinedEvents(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            AppLogger.error(
                                "Error fetching events: ${snapshot.error}");
                            return const Center(
                                child: Text(CustomString.errorFetchingEvents));
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final events = snapshot.data!;

                          if (events.isEmpty) {
                            return const Center(
                                child: Text(CustomString.noEventsAvailable));
                          }

                          return ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final isTurn =
                                  event.reference.parent.id == 'turns';

                              if (isTurn) {
                                // Display TURN event
                                return TurnCardContent(
                                  profilePictureUrl:
                                      event['profilePictureUrl'] ??
                                          CustomString.emptyString,
                                  username: event['username'] ??
                                      CustomString.emptyString,
                                  organizers: List<String>.from(
                                      event['organizers'] ?? []),
                                  timeInfo:
                                      'une heure', // Placeholder for time info
                                  turnName: event['turnName'] ??
                                      CustomString.emptyString,
                                  description: event['description'] ??
                                      CustomString.emptyString,
                                  eventDateTime: viewModel
                                      .parseDate(event['eventDateTime']),
                                  where: event['where'] ??
                                      CustomString.emptyString,
                                  address: event['address'] ??
                                      CustomString.emptyString,
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
                                // Display CFQ event
                                return CFQCardContent(
                                  profilePictureUrl:
                                      event['profilePictureUrl'] ??
                                          CustomString.emptyString,
                                  username: event['username'] ??
                                      CustomString.emptyString,
                                  organizers: List<String>.from(
                                      event['organizers'] ?? []),
                                  cfqName: event['cfqName'] ??
                                      CustomString.emptyString,
                                  description: event['description'] ??
                                      CustomString.emptyString,
                                  datePublished: viewModel
                                      .parseDate(event['datePublished']),
                                  location: event['where'] ??
                                      CustomString.emptyString,
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
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
