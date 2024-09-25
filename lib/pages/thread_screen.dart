import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cfq_dev/organisms/turn_card_content.dart';
import 'package:cfq_dev/organisms/cfq_card_content.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:cfq_dev/utils/string.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  // Helper function to parse date
  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        print("Warning: Could not parse date as DateTime: $date");
        return DateTime.now(); // Fallback to current date
      }
    } else if (date is DateTime) {
      return date;
    } else {
      print("Warning: Unknown type for date: $date");
      return DateTime.now(); // Fallback to current date
    }
  }

  // Fetch turns and cfqs and combine them into a single stream
  Stream<List<DocumentSnapshot>> fetchCombinedEvents() {
    try {

      // Fetch turns
      Stream<QuerySnapshot> turnsStream = FirebaseFirestore.instance
          .collection('turns')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Fetch cfqs
      Stream<QuerySnapshot> cfqsStream = FirebaseFirestore.instance
          .collection('cfqs')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Combine both streams using Rx.combineLatest2 from rxdart
      return Rx.combineLatest2(turnsStream, cfqsStream,
          (QuerySnapshot turnsSnapshot, QuerySnapshot cfqsSnapshot) {
        // Debug logs for turns and cfqs snapshots
        print("Turns snapshot docs count: ${turnsSnapshot.docs.length}");
        print("CFQs snapshot docs count: ${cfqsSnapshot.docs.length}");

        // Merge the docs from both collections
        List<DocumentSnapshot> allDocs = [];
        allDocs.addAll(turnsSnapshot.docs);
        allDocs.addAll(cfqsSnapshot.docs);

        // Helper function to get date for sorting
        DateTime getDate(DocumentSnapshot doc) {
          dynamic date;
          if (doc.reference.parent.id == 'turns') {
            date = doc['eventDateTime'];
          } else if (doc.reference.parent.id == 'cfqs') {
            date = doc['datePublished'];
          } else {
            date = DateTime.now(); // Default to now if unknown collection
          }
          return parseDate(date);
        }

        // Sort combined events by their respective dates
        allDocs.sort((a, b) {
          try {
            DateTime dateTimeA = getDate(a);
            DateTime dateTimeB = getDate(b);
            // Compare the two DateTime objects
            return dateTimeB.compareTo(dateTimeA); // Sort descending
          } catch (error) {
            print("Error while sorting events: $error");
            return 0; // Avoid crashing on errors
          }
        });

        print("Total events after merging and sorting: ${allDocs.length}");
        return allDocs;
      });
    } catch (error) {
      print("Error in fetchCombinedEvents: $error");
      rethrow;
    }
  }

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
                stream: fetchCombinedEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("Error fetching events: ${snapshot.error}");
                    return const Center(
                        child: Text(CustomString.errorFetchingEvents));
                  }
                  if (!snapshot.hasData) {
                    print(CustomString.fetchingDataNoEventsYet);
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!;
                  print("Number of events to display: ${events.length}");

                  if (events.isEmpty) {
                    print("No events found");
                    return const Center(
                        child: Text(CustomString.noEventsAvailable));
                  }

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isTurn = event.reference.parent.id == 'turns';

                      print(
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
                          eventDateTime: parseDate(event['eventDateTime']),
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
                          datePublished: parseDate(event['datePublished']),
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
