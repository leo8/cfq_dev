import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/widgets/organisms/turn_card_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/styles/string.dart';
import 'cfq_card_content.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>> eventsStream;

  const EventsList({
    required this.eventsStream,
    super.key,
  });

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date as DateTime: $date");
        return DateTime.now();
      }
    } else if (date is DateTime) {
      return date;
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: eventsStream,
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
                turnImageUrl: event['turnImageUrl'] ?? '',
                profilePictureUrl: event['profilePictureUrl'] ?? '',
                username: event['username'] ?? '',
                organizers: List<String>.from(event['organizers'] ?? []),
                turnName: event['turnName'] ?? '',
                description: event['description'] ?? '',
                eventDateTime: parseDate(event['eventDateTime']),
                where: event['where'] ?? '',
                address: event['address'] ?? '',
                attendeesCount: (event['attending'] as List?)?.length ?? 0,
                datePublished: parseDate(event['datePublished']),
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
              return CFQCardContent(
                cfqImageUrl: event['cfqImageUrl'] ?? '',
                profilePictureUrl: event['profilePictureUrl'] ?? '',
                username: event['username'] ?? '',
                organizers: List<String>.from(event['organizers'] ?? []),
                cfqName: event['cfqName'] ?? '',
                description: event['description'] ?? '',
                datePublished: parseDate(event['datePublished']),
                location: event['where'] ?? '',
                when: event['when'] ?? '',
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
