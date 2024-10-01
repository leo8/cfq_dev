import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/widgets/organisms/turn_card_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/styles/string.dart';
import 'cfq_card_content.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>>
      eventsStream; // Stream of event snapshots

  const EventsList({
    required this.eventsStream,
    super.key,
  });

  // Parses the provided date into a DateTime object.
  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate(); // Convert Timestamp to DateTime
    } else if (date is String) {
      try {
        return DateTime.parse(date); // Parse string date
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date as DateTime: $date");
        return DateTime.now(); // Fallback to current date on error
      }
    } else if (date is DateTime) {
      return date; // Already a DateTime
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now(); // Fallback to current date for unknown types
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: eventsStream, // Listen to the events stream
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          AppLogger.error("Error fetching events: ${snapshot.error}");
          return const Center(
              child: Text(
                  CustomString.errorFetchingEvents)); // Display error message
        }
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(
              child: Text(CustomString
                  .noEventsAvailable)); // Show message if no events found
        }

        return ListView.builder(
          itemCount: events.length, // Number of events to display
          itemBuilder: (context, index) {
            final event = events[index];
            final isTurn = event.reference.parent.id ==
                'turns'; // Check if the event is a turn

            if (isTurn) {
              // Create a TurnCardContent for turn events
              return TurnCardContent(
                profilePictureUrl:
                    event['profilePictureUrl'] ?? '', // Profile picture URL
                username: event['username'] ?? '', // Username
                organizers: List<String>.from(
                    event['organizers'] ?? []), // List of organizers
                timeInfo: 'une heure', // Placeholder for time info
                turnName: event['turnName'] ?? '', // Turn name
                description: event['description'] ?? '', // Event description
                eventDateTime: parseDate(
                    event['eventDateTime']), // Parsed event date and time
                where: event['where'] ?? '', // Event location
                address: event['address'] ?? '', // Event address
                onAttendingPressed: () {
                  // Handle attending action (to be implemented)
                },
                onSharePressed: () {
                  // Handle share action (to be implemented)
                },
                onSendPressed: () {
                  // Handle send action (to be implemented)
                },
                onCommentPressed: () {
                  // Handle comment action (to be implemented)
                },
              );
            } else {
              // Create a CFQCardContent for CFQ events
              return CFQCardContent(
                profilePictureUrl:
                    event['profilePictureUrl'] ?? '', // Profile picture URL
                username: event['username'] ?? '', // Username
                organizers: List<String>.from(
                    event['organizers'] ?? []), // List of organizers
                cfqName: event['cfqName'] ?? '', // CFQ name
                description: event['description'] ?? '', // Event description
                datePublished: parseDate(
                    event['datePublished']), // Parsed event date published
                location: event['where'] ?? '', // Event location
                onFollowPressed: () {
                  // Handle follow action (to be implemented)
                },
                onSharePressed: () {
                  // Handle share action (to be implemented)
                },
                onSendPressed: () {
                  // Handle send action (to be implemented)
                },
                onCommentPressed: () {
                  // Handle comment action (to be implemented)
                },
              );
            }
          },
        );
      },
    );
  }
}
