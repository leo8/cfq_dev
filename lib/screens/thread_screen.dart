import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/view_model/thread_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../widgets/organisms/turn_card_content.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  
  final viewModel = ThreadViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Make the app bar transparent over the background
      appBar: AppBar(
        backgroundColor: CustomColor.transparent, // Transparent app bar
        elevation: 0,
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: CustomColor.white24,
                  prefixIcon:
                      const Icon(CustomIcon.search, color: CustomColor.white70),
                  hintText: CustomString.chercherDesUtilisateurs,
                  hintStyle: const TextStyle(color: CustomColor.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Notification Bell Button
            IconButton(
              icon: const Icon(CustomIcon.notifications,
                  color: CustomColor.primaryColor),
              onPressed: () {
                // Add function later
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            ),
            fit: BoxFit.cover, // Background image covering the whole screen
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 135), // Add spacing from the top
            // Horizontal list of profile pictures
            Container(
              height: 100, // Adjusted height to allow space beneath avatars
              padding: const EdgeInsets.only(left: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Assume we are displaying 5 profile pictures
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          CustomString.username, // Sample username for now
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
            const SizedBox(height: 20), // Extra space below profile avatars
            Expanded(
              // Fetch and display combined events sorted by date
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: viewModel.fetchCombinedEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    AppLogger.error("Error fetching events: ${snapshot.error}");
                    return const Center(
                        child: Text(CustomString.errorFetchingEvents));
                  }
                  if (!snapshot.hasData) {
                    AppLogger.error(CustomString.fetchingDataNoEventsYet);
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!;
                  AppLogger.info("Number of events to display: ${events.length}");

                  if (events.isEmpty) {
                    AppLogger.debug("No events found");
                    return const Center(
                        child: Text(CustomString.noEventsAvailable));
                  }

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isTurn = event.reference.parent.id == 'turns';

                      AppLogger.debug(
                          "Displaying event from collection: ${event.reference.parent.id}");

                      if (isTurn) {
                        // Display TurnCardContent
                        return TurnCardContent(
                          profilePictureUrl:
                              event['profilePictureUrl'] ?? CustomString.emptyString,
                          username: event['username'] ?? CustomString.emptyString,
                          organizers:
                              List<String>.from(event['organizers'] ?? []),
                          timeInfo: 'une heure', // Compute as needed
                          turnName: event['turnName'] ?? CustomString.emptyString,
                          description:
                              event['description'] ?? CustomString.emptyString,
                          eventDateTime: viewModel.parseDate(event['eventDateTime']),
                          where: event['where'] ?? CustomString.emptyString,
                          address: event['address'] ?? CustomString.emptyString,
                          onAttendingPressed: () {
                            // Handle attending action
                          },
                          onSharePressed: () {
                            // Handle share action
                          },
                          onSendPressed: () {
                            // Handle send action
                          },
                          onCommentPressed: () {
                            // Handle comment action
                          },
                        );
                      } else {
                        // Display CFQCardContent
                        return CFQCardContent(
                          profilePictureUrl:
                              event['profilePictureUrl'] ?? CustomString.emptyString,
                          username: event['username'] ?? CustomString.emptyString,
                          organizers:
                              List<String>.from(event['organizers'] ?? []),
                          cfqName: event['cfqName'] ?? CustomString.emptyString,
                          description:
                              event['description'] ?? CustomString.emptyString,
                          datePublished: viewModel.parseDate(event['datePublished']),
                          location: event['where'] ?? CustomString.emptyString,
                          onFollowPressed: () {
                            // Handle follow action
                          },
                          onSharePressed: () {
                            // Handle share action
                          },
                          onSendPressed: () {
                            // Handle send action
                          },
                          onCommentPressed: () {
                            // Handle comment action
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
