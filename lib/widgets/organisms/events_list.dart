import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/widgets/organisms/turn_card_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart' as model;
import '../../screens/conversation_screen.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/text_styles.dart';
import 'cfq_card_content.dart';
import '../molecules/private_turn_card.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>> eventsStream;
  final model.User? currentUser;
  final Function(String, bool) onFavoriteToggle;
  final Function(String) addConversationToUserList;
  final Function(String) removeConversationFromUserList;
  final Function(String) isConversationInUserList;
  final Future<void> Function(String) resetUnreadMessages;
  final Future<void> Function(String, String) addFollowUp;
  final Future<void> Function(String, String) removeFollowUp;
  final Stream<bool> Function(String, String) isFollowingUpStream;
  final Future<void> Function(String, String) toggleFollowUp;
  final Function(String, String) onAttendingStatusChanged;
  final Stream<String> Function(String, String) attendingStatusStream;
  final Stream<int> Function(String) attendingCountStream;

  const EventsList({
    required this.eventsStream,
    required this.currentUser,
    required this.onFavoriteToggle,
    required this.addConversationToUserList,
    required this.removeConversationFromUserList,
    required this.isConversationInUserList,
    required this.resetUnreadMessages,
    required this.addFollowUp,
    required this.removeFollowUp,
    required this.isFollowingUpStream,
    required this.toggleFollowUp,
    required this.onAttendingStatusChanged,
    required this.attendingCountStream,
    required this.attendingStatusStream,
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
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: MediaQuery.of(context).size.height *
                    0.5, // 50% of screen height
                child: Center(
                  child: Text(
                    CustomString.noEventsAvailable,
                    style: CustomTextStyle.body1,
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          AppLogger.error("Error fetching events: ${snapshot.error}");
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight,
                child: Center(
                  child: Text(
                    CustomString.errorFetchingEvents,
                    style: CustomTextStyle.body1,
                  ),
                ),
              );
            },
          );
        }

        final events = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final event = events[index];
            final documentId = event.id;
            final eventData = event.data() as Map<String, dynamic>? ?? {};
            final isTurn = event.reference.parent.id == 'turns';

            final isFavorite =
                currentUser?.favorites.contains(documentId) ?? false;

            if (isTurn) {
              final List<String> invitees =
                  List<String>.from(eventData['invitees'] ?? []);
              final List<String> organizers =
                  List<String>.from(eventData['organizers'] ?? []);

              if (!invitees.contains(currentUser!.uid) &&
                  !organizers.contains(currentUser!.uid)) {
                return PrivateTurnCard(
                  eventDateTime: parseDate(eventData['eventDateTime']),
                );
              }

              String attendingStatus = 'notAnswered';
              if (eventData['attending']?.contains(currentUser!.uid) ?? false) {
                attendingStatus = 'attending';
              } else if (eventData['notSureAttending']
                      ?.contains(currentUser!.uid) ??
                  false) {
                attendingStatus = 'notSureAttending';
              } else if (eventData['notAttending']
                      ?.contains(currentUser!.uid) ??
                  false) {
                attendingStatus = 'notAttending';
              }

              return TurnCardContent(
                turnImageUrl:
                    eventData['turnImageUrl'] ?? CustomString.emptyString,
                profilePictureUrl:
                    eventData['profilePictureUrl'] ?? CustomString.emptyString,
                username: eventData['username'] ?? CustomString.emptyString,
                organizers: List<String>.from(eventData['organizers'] ?? []),
                turnName: eventData['turnName'] ?? CustomString.emptyString,
                description:
                    eventData['description'] ?? CustomString.emptyString,
                eventDateTime: parseDate(eventData['eventDateTime']),
                where: eventData['where'] ?? CustomString.emptyString,
                address: eventData['address'] ?? CustomString.emptyString,
                datePublished: parseDate(eventData['datePublished']),
                moods: List<String>.from(eventData['moods'] ?? []),
                turnId: eventData['turnId'] ?? CustomString.emptyString,
                organizerId: eventData['uid'] ?? CustomString.emptyString,
                currentUserId: currentUser!.uid,
                favorites: currentUser!.favorites,
                onAttendingPressed: () {
                  // Handle attending action
                },
                attendingStatusStream:
                    attendingStatusStream(documentId, currentUser!.uid),
                attendingCountStream: attendingCountStream(documentId),
                onAttendingStatusChanged: (status) =>
                    onAttendingStatusChanged(documentId, status),
                onSharePressed: () {
                  // Handle share action
                },
                onSendPressed: () async {
                  if (eventData['channelId'] != null) {
                    // Create a new list that includes both invitees and the organizer
                    List<String> allMembers =
                        List<String>.from(eventData['invitees'] ?? []);
                    if (!allMembers.contains(eventData['uid'])) {
                      allMembers
                          .add(eventData['uid']); // Add the organizer's UID
                    }
                    bool isInUserList =
                        await isConversationInUserList(eventData['channelId']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          eventName: isTurn
                              ? eventData['turnName']
                              : eventData['cfqName'],
                          channelId: eventData['channelId'],
                          organizerId: eventData['uid'],
                          members: (eventData['invitees'] as List<dynamic>)
                              .cast<String>(), // Cast to List<String
                          organizerName: eventData['username'],
                          organizerProfilePicture:
                              eventData['profilePictureUrl'],
                          currentUser: currentUser!,
                          addConversationToUserList: addConversationToUserList,
                          removeConversationFromUserList:
                              removeConversationFromUserList,
                          initialIsInUserConversations: isInUserList,
                          eventPicture: isTurn
                              ? eventData['turnImageUrl']
                              : eventData['cfqImageUrl'],
                          resetUnreadMessages: resetUnreadMessages,
                        ),
                      ),
                    );
                  } else {
                    // Handle the case where no channel exists for this event
                  }
                },
                onCommentPressed: () {
                  // Handle comment action
                },
                isFavorite: isFavorite,
                onFavoritePressed: () =>
                    onFavoriteToggle(documentId, !isFavorite),
                attendingStatus: attendingStatus,
              );
            } else {
              return StreamBuilder<bool>(
                stream: isFollowingUpStream(documentId, currentUser!.uid),
                builder: (context, followUpSnapshot) {
                  return CFQCardContent(
                    cfqImageUrl:
                        eventData['cfqImageUrl'] ?? CustomString.emptyString,
                    profilePictureUrl: eventData['profilePictureUrl'] ??
                        CustomString.emptyString,
                    username: eventData['username'] ?? CustomString.emptyString,
                    organizers:
                        List<String>.from(eventData['organizers'] ?? []),
                    cfqName: eventData['cfqName'] ?? CustomString.emptyString,
                    description:
                        eventData['description'] ?? CustomString.emptyString,
                    datePublished: parseDate(eventData['datePublished']),
                    location: eventData['where'] ?? CustomString.emptyString,
                    when: eventData['when'] ?? CustomString.emptyString,
                    moods: List<String>.from(eventData['moods'] ?? []),
                    followingUp:
                        List<String>.from(eventData['followingUp'] ?? []),
                    cfqId: documentId,
                    organizerId: eventData['uid'] ?? CustomString.emptyString,
                    currentUserId: currentUser!.uid,
                    favorites: currentUser!.favorites,
                    isFavorite: isFavorite,
                    onFollowUpToggled: (bool newValue) {
                      toggleFollowUp(documentId, currentUser!.uid);
                    },
                    onFollowPressed: () {
                      // Handle follow action
                    },
                    onSendPressed: () async {
                      if (eventData['channelId'] != null) {
                        bool isInUserList = await isConversationInUserList(
                            eventData['channelId']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationScreen(
                              eventName: eventData['cfqName'],
                              channelId: eventData['channelId'],
                              organizerId: eventData['uid'],
                              members: (eventData['invitees'] as List<dynamic>)
                                  .cast<String>(), // Cast to List<String
                              organizerName: eventData['username'],
                              organizerProfilePicture:
                                  eventData['profilePictureUrl'],
                              currentUser: currentUser!,
                              addConversationToUserList:
                                  addConversationToUserList,
                              removeConversationFromUserList:
                                  removeConversationFromUserList,
                              initialIsInUserConversations: isInUserList,
                              eventPicture: eventData['cfqImageUrl'],
                              resetUnreadMessages: resetUnreadMessages,
                            ),
                          ),
                        );
                      } else {
                        // Handle the case where no channel exists for this event
                      }
                    },
                    onSharePressed: () {
                      // Handle share action
                    },
                    onFavoritePressed: () =>
                        onFavoriteToggle(documentId, !isFavorite),
                    onBellPressed: () {
                      // Handle comment action
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
