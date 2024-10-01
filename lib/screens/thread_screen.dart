import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/view_models/thread_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../widgets/organisms/turn_card_content.dart';

/// ThreadScreen displays a list of events (both CFQs and Turns) sorted by date.
/// It uses a ViewModel to fetch and process data from Firebase.
class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  // ViewModel to handle data fetching and business logic
  final viewModel = ThreadViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // App bar overlaps with the background image
      appBar: AppBar(
        backgroundColor: CustomColor.transparent, // Transparent app bar
        elevation: 0, // Remove shadow under the app bar
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: CustomColor.white24, // Semi-transparent background
                  prefixIcon: const Icon(
                    CustomIcon.search,
                    color: CustomColor.white70,
                  ), // Search icon
                  hintText:
                      CustomString.chercherDesUtilisateurs, // Placeholder text
                  hintStyle: const TextStyle(
                      color: CustomColor.white70), // Text style for placeholder
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded borders
                    borderSide: BorderSide.none, // No border
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Notification bell icon (currently without functionality)
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
        ),
      ),
      // Body with background image and event list
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            ),
            fit: BoxFit.cover, // Cover the entire background with the image
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 135), // Space between top and content
            // Horizontal list of profile pictures
            Container(
              height: 100, // Set height for the avatar row
              padding: const EdgeInsets.only(left: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                itemCount: 5, // Placeholder for 5 profile avatars
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        // Circle avatar representing a user profile
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        SizedBox(height: 5),
                        // Placeholder for username below each avatar
                        Text(
                          CustomString.username,
                          style: TextStyle(
                              color: CustomColor.white70,
                              fontSize: CustomFont.fontSize12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20), // Extra space after avatars
            // Event list area
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: viewModel
                    .fetchCombinedEvents(), // Stream of events from Firebase
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Log and display error message if the stream fails
                    AppLogger.error("Error fetching events: ${snapshot.error}");
                    return const Center(
                        child: Text(CustomString.errorFetchingEvents));
                  }
                  if (!snapshot.hasData) {
                    // Log and show progress indicator while data is being fetched
                    AppLogger.error(CustomString.fetchingDataNoEventsYet);
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!;
                  AppLogger.info(
                      "Number of events to display: ${events.length}");

                  if (events.isEmpty) {
                    // Log and display a message if there are no events
                    AppLogger.debug("No events found");
                    return const Center(
                        child: Text(CustomString.noEventsAvailable));
                  }

                  return ListView.builder(
                    itemCount: events.length, // Number of events to display
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isTurn = event.reference.parent.id ==
                          'turns'; // Check if it's a TURN event

                      AppLogger.debug(
                          "Displaying event from collection: ${event.reference.parent.id}");

                      // Show TURN or CFQ card depending on the event type
                      if (isTurn) {
                        // Display TURN event
                        return TurnCardContent(
                          profilePictureUrl: event['profilePictureUrl'] ??
                              CustomString.emptyString,
                          username:
                              event['username'] ?? CustomString.emptyString,
                          organizers:
                              List<String>.from(event['organizers'] ?? []),
                          timeInfo: 'une heure', // Placeholder for time info
                          turnName:
                              event['turnName'] ?? CustomString.emptyString,
                          description:
                              event['description'] ?? CustomString.emptyString,
                          eventDateTime:
                              viewModel.parseDate(event['eventDateTime']),
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
                        // Display CFQ event
                        return CFQCardContent(
                          profilePictureUrl: event['profilePictureUrl'] ??
                              CustomString.emptyString,
                          username:
                              event['username'] ?? CustomString.emptyString,
                          organizers:
                              List<String>.from(event['organizers'] ?? []),
                          cfqName: event['cfqName'] ?? CustomString.emptyString,
                          description:
                              event['description'] ?? CustomString.emptyString,
                          datePublished:
                              viewModel.parseDate(event['datePublished']),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
