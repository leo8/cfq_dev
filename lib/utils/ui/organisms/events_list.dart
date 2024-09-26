import 'package:cfq_dev/utils/ui/organisms/turn_card_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../gen/string.dart';
import 'cfq_card_content.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>> eventsStream;

  const EventsList({
    required this.eventsStream,
    super.key,
  });

  // Helper function to parse date if not already available in utils.dart
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: eventsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching events: ${snapshot.error}");
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
              // Extract and pass the required data to TurnCardContent
              return TurnCardContent(
                profilePictureUrl: event['profilePictureUrl'] ?? '',
                username: event['username'] ?? '',
                organizers: List<String>.from(event['organizers'] ?? []),
                timeInfo: 'une heure', // Placeholder or compute as needed
                turnName: event['turnName'] ?? '',
                description: event['description'] ?? '',
                eventDateTime: parseDate(event['eventDateTime']),
                where: event['where'] ?? '',
                address: event['address'] ?? '',
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
              // Extract and pass the required data to CFQCardContent
              return CFQCardContent(
                profilePictureUrl: event['profilePictureUrl'] ?? '',
                username: event['username'] ?? '',
                organizers: List<String>.from(event['organizers'] ?? []),
                cfqName: event['cfqName'] ?? '',
                description: event['description'] ?? '',
                datePublished: parseDate(event['datePublished']),
                location: event['where'] ?? '',
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
    );
  }
}
