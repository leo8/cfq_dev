import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/widgets/organisms/turn_card_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart' as model;
import '../../screens/conversation_screen.dart';
import '../../utils/styles/string.dart';
import 'cfq_card_content.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>> eventsStream;
  final model.User? currentUser;
  final Function(String, bool) onFavoriteToggle;

  const EventsList({
    required this.eventsStream,
    required this.currentUser,
    required this.onFavoriteToggle,
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
            final eventId = isTurn ? event['turnId'] : event['cfqId'];
            final isFavorite =
                currentUser?.favorites.contains(eventId) ?? false;

            if (isTurn) {
              return TurnCardContent(
                turnImageUrl: event['turnImageUrl'] ?? CustomString.emptyString,
                profilePictureUrl:
                    event['profilePictureUrl'] ?? CustomString.emptyString,
                username: event['username'] ?? CustomString.emptyString,
                organizers: List<String>.from(event['organizers'] ?? []),
                turnName: event['turnName'] ?? CustomString.emptyString,
                description: event['description'] ?? CustomString.emptyString,
                eventDateTime: parseDate(event['eventDateTime']),
                where: event['where'] ?? CustomString.emptyString,
                address: event['address'] ?? CustomString.emptyString,
                attendeesCount: (event['attending'] as List?)?.length ?? 0,
                datePublished: parseDate(event['datePublished']),
                moods: List<String>.from(event['moods'] ?? []),
                turnId: event['turnId'] ?? CustomString.emptyString,
                organizerId: event['uid'] ?? CustomString.emptyString,
                currentUserId: currentUser!.uid,
                favorites: currentUser!.favorites,
                onAttendingPressed: () {
                  // Handle attending action
                },
                onSharePressed: () {
                  // Handle share action
                },
                onSendPressed: () {
                  if (event['channelId'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                            eventName: event['turnName'],
                            channelId: event['channelId']),
                      ),
                    );
                  } else {
                    // Handle the case where no channel exists for this turn
                  }
                  // Handle send action
                },
                onCommentPressed: () {
                  // Handle comment action
                },
                isFavorite: isFavorite,
                onFavoritePressed: () => onFavoriteToggle(eventId, !isFavorite),
              );
            } else {
              return CFQCardContent(
                cfqImageUrl: event['cfqImageUrl'] ?? CustomString.emptyString,
                profilePictureUrl:
                    event['profilePictureUrl'] ?? CustomString.emptyString,
                username: event['username'] ?? CustomString.emptyString,
                organizers: List<String>.from(event['organizers'] ?? []),
                cfqName: event['cfqName'] ?? CustomString.emptyString,
                description: event['description'] ?? CustomString.emptyString,
                datePublished: parseDate(event['datePublished']),
                location: event['where'] ?? CustomString.emptyString,
                when: event['when'] ?? CustomString.emptyString,
                moods: List<String>.from(event['moods'] ?? []),
                followersCount: 0,
                cfqId: event['cfqId'] ?? CustomString.emptyString,
                organizerId: event['uid'] ?? CustomString.emptyString,
                currentUserId: currentUser!.uid,
                favorites: currentUser!.favorites,
                onFollowPressed: () {
                  // Handle follow action
                },
                onSendPressed: () {
                  if (event['channelId'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                            eventName: event['cfqName'],
                            channelId: event['channelId']),
                      ),
                    );
                  } else {
                    // Handle the case where no channel exists for this turn
                  }
                  // Handle send action
                },
                onSharePressed: () {
                  // Handle share action
                },
                onFavoritePressed: () => onFavoriteToggle(eventId, !isFavorite),
                onBellPressed: () {
                  // Handle comment action
                },
                isFavorite: isFavorite,
              );
            }
          },
        );
      },
    );
  }
}
