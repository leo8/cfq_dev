import 'package:cfq_dev/view_models/requests_view_model.dart';
import 'package:flutter/material.dart';
import '../../models/notification.dart' as notificationModel;
import '../molecules/notification_card.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';
import '../../utils/logger.dart';
import 'cfq_card_content.dart';
import 'turn_card_content.dart';
import '../../screens/expanded_card_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/requests_screen.dart';
import 'package:cfq_dev/view_models/notifications_view_model.dart';
import '../../screens/conversation_screen.dart';

class NotificationsList extends StatelessWidget {
  final List<notificationModel.Notification> notifications;
  final bool isLoading;
  final Stream<int> unreadCountStream;
  final String currentUserId;
  final NotificationsViewModel viewModel;

  const NotificationsList({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.unreadCountStream,
    required this.currentUserId,
    required this.viewModel,
  });

  Future<Map<String, dynamic>> _fetchEventData(
      String eventId, bool isTurn) async {
    try {
      final collection = isTurn ? 'turns' : 'cfqs';
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(eventId)
          .get();

      if (!doc.exists) {
        throw Exception('Event not found');
      }

      final data = Map<String, dynamic>.from(doc.data()!);

      // Handle date fields
      if (data['datePublished'] is Timestamp) {
        data['datePublished'] = (data['datePublished'] as Timestamp).toDate();
      } else if (data['datePublished'] is String) {
        data['datePublished'] = DateTime.parse(data['datePublished']);
      } else {
        data['datePublished'] = DateTime.now(); // Fallback
      }

      if (isTurn && data['eventDateTime'] != null) {
        if (data['eventDateTime'] is Timestamp) {
          data['eventDateTime'] = (data['eventDateTime'] as Timestamp).toDate();
        } else if (data['eventDateTime'] is String) {
          data['eventDateTime'] = DateTime.parse(data['eventDateTime']);
        }
      }

      // Ensure all required fields have default values
      return {
        'uid': data['uid'] ?? '',
        'organizers': List<String>.from(data['organizers'] ?? []),
        'moods': List<String>.from(data['moods'] ?? []),
        'description': data['description'] ?? '',
        'datePublished': data['datePublished'],
        'favorites': List<String>.from(data['favorites'] ?? []),
        'followingUp': List<String>.from(data['followingUp'] ?? []),
        ...isTurn
            ? {
                'turnName': data['turnName'] ?? '',
                'turnImageUrl': data['turnImageUrl'] ?? '',
                'where': data['where'] ?? '',
                'address': data['address'] ?? '',
                'eventDateTime': data['eventDateTime'] ?? DateTime.now(),
              }
            : {
                'cfqName': data['cfqName'] ?? '',
                'cfqImageUrl': data['cfqImageUrl'] ?? '',
                'location': data['location'] ?? '',
                'when': data['when'] ?? '',
              },
      };
    } catch (e) {
      AppLogger.error('Error fetching event data: $e');
      throw Exception('Failed to fetch event data');
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data()!;
      return {
        'profilePictureUrl': data['profilePictureUrl'] ?? '',
        'username': data['username'] ?? 'Unknown User',
      };
    } catch (e) {
      AppLogger.error('Error fetching user data: $e');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<Widget> _buildCardContent(
      BuildContext context, notificationModel.Notification notification) async {
    try {
      final content = notification.content;

      switch (notification.type) {
        case notificationModel.NotificationType.followUp:
          final followUpContent =
              content as notificationModel.FollowUpNotificationContent;
          final cfqData = await _fetchEventData(followUpContent.cfqId, false);
          final userData = await _fetchUserData(cfqData['uid']);

          return CFQCardContent(
            cfqId: followUpContent.cfqId,
            profilePictureUrl: userData['profilePictureUrl'],
            username: userData['username'],
            organizers: cfqData['organizers'],
            moods: cfqData['moods'],
            cfqName: cfqData['cfqName'],
            description: cfqData['description'],
            datePublished: cfqData['datePublished'],
            cfqImageUrl: cfqData['cfqImageUrl'],
            location: cfqData['location'],
            when: cfqData['when'],
            followingUp: cfqData['followingUp'],
            onFollowPressed: () {},
            onSharePressed: () {},
            onBellPressed: () {},
            organizerId: cfqData['uid'],
            currentUserId: currentUserId,
            favorites: cfqData['favorites'],
            isFavorite: cfqData['favorites'].contains(currentUserId),
            onFollowUpToggled: (isFollowingUp) async {
              await viewModel.toggleFollowUp(
                  followUpContent.cfqId, currentUserId);
            },
            onFavoritePressed: () async {
              await viewModel.toggleFavorite(
                followUpContent.cfqId,
                !cfqData['favorites'].contains(currentUserId),
              );
            },
            onSendPressed: () async {
              if (context.mounted) {
                try {
                  final channelId = followUpContent.cfqId;
                  final isInList =
                      await viewModel.isConversationInUserList(channelId);
                  final currentUser = await viewModel.getCurrentUser();

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          eventName: cfqData['cfqName'],
                          channelId: channelId,
                          organizerId: cfqData['uid'],
                          members: List<String>.from(cfqData['invitees'] ?? []),
                          organizerName: userData['username'],
                          organizerProfilePicture:
                              userData['profilePictureUrl'],
                          currentUser: currentUser,
                          addConversationToUserList:
                              viewModel.addConversationToUserList,
                          removeConversationFromUserList:
                              viewModel.removeConversationFromUserList,
                          initialIsInUserConversations: isInList,
                          eventPicture: cfqData['cfqImageUrl'],
                          resetUnreadMessages: viewModel.resetUnreadMessages,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  AppLogger.error('Error navigating to conversation: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error opening conversation')),
                    );
                  }
                }
              }
            },
            followersCountStream:
                viewModel.followersCountStream(followUpContent.cfqId),
          );

        case notificationModel.NotificationType.eventInvitation:
          final eventContent =
              content as notificationModel.EventInvitationNotificationContent;
          final eventData =
              await _fetchEventData(eventContent.eventId, eventContent.isTurn);
          final userData = await _fetchUserData(eventData['uid']);

          return eventContent.isTurn
              ? TurnCardContent(
                  turnId: eventContent.eventId,
                  profilePictureUrl: userData['profilePictureUrl'],
                  username: userData['username'],
                  organizers: eventData['organizers'],
                  turnName: eventData['turnName'],
                  description: eventData['description'],
                  eventDateTime: eventData['eventDateTime'],
                  datePublished: eventData['datePublished'],
                  turnImageUrl: eventData['turnImageUrl'],
                  where: eventData['where'],
                  address: eventData['address'],
                  moods: eventData['moods'],
                  organizerId: eventData['uid'],
                  currentUserId: currentUserId,
                  favorites: eventData['favorites'],
                  isFavorite: eventData['favorites'].contains(currentUserId),
                  attendingStatus: 'notAnswered',
                  onAttendingStatusChanged: (status) async {
                    await viewModel.updateAttendingStatus(
                        eventContent.eventId, status);
                  },
                  onSharePressed: () {},
                  onSendPressed: () async {
                    if (context.mounted) {
                      try {
                        final channelId = eventContent.eventId;
                        final isInList =
                            await viewModel.isConversationInUserList(channelId);
                        final currentUser = await viewModel.getCurrentUser();

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                eventName: eventData['turnName'],
                                channelId: channelId,
                                organizerId: eventData['uid'],
                                members: List<String>.from(
                                    eventData['invitees'] ?? []),
                                organizerName: userData['username'],
                                organizerProfilePicture:
                                    userData['profilePictureUrl'],
                                currentUser: currentUser,
                                addConversationToUserList:
                                    viewModel.addConversationToUserList,
                                removeConversationFromUserList:
                                    viewModel.removeConversationFromUserList,
                                initialIsInUserConversations: isInList,
                                eventPicture: eventData['turnImageUrl'],
                                resetUnreadMessages:
                                    viewModel.resetUnreadMessages,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        AppLogger.error('Error navigating to conversation: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error opening conversation')),
                          );
                        }
                      }
                    }
                  },
                  onFavoritePressed: () async {
                    await viewModel.toggleFavorite(
                      eventContent.eventId,
                      !eventData['favorites'].contains(currentUserId),
                    );
                  },
                  onCommentPressed: () {},
                  onAttendingPressed: () {},
                  attendingStatusStream: viewModel.attendingStatusStream(
                    eventContent.eventId,
                    currentUserId,
                  ),
                  attendingCountStream:
                      viewModel.attendingCountStream(eventContent.eventId),
                )
              : CFQCardContent(
                  cfqId: eventContent.eventId,
                  profilePictureUrl: userData['profilePictureUrl'],
                  username: userData['username'],
                  organizers: eventData['organizers'],
                  moods: eventData['moods'],
                  cfqName: eventData['cfqName'],
                  description: eventData['description'],
                  datePublished: eventData['datePublished'],
                  cfqImageUrl: eventData['cfqImageUrl'],
                  location: eventData['location'],
                  when: eventData['when'],
                  followingUp: eventData['followingUp'],
                  onFollowPressed: () {},
                  onSharePressed: () {},
                  onSendPressed: () async {
                    if (context.mounted) {
                      try {
                        final channelId = eventContent.eventId;
                        final isInList =
                            await viewModel.isConversationInUserList(channelId);
                        final currentUser = await viewModel.getCurrentUser();

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                eventName: eventData['turnName'],
                                channelId: channelId,
                                organizerId: eventData['uid'],
                                members: List<String>.from(
                                    eventData['invitees'] ?? []),
                                organizerName: userData['username'],
                                organizerProfilePicture:
                                    userData['profilePictureUrl'],
                                currentUser: currentUser,
                                addConversationToUserList:
                                    viewModel.addConversationToUserList,
                                removeConversationFromUserList:
                                    viewModel.removeConversationFromUserList,
                                initialIsInUserConversations: isInList,
                                eventPicture: eventData['turnImageUrl'],
                                resetUnreadMessages:
                                    viewModel.resetUnreadMessages,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        AppLogger.error('Error navigating to conversation: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error opening conversation')),
                          );
                        }
                      }
                    }
                  },
                  onFavoritePressed: () async {
                    await viewModel.toggleFavorite(
                      eventContent.eventId,
                      !eventData['favorites'].contains(currentUserId),
                    );
                  },
                  onBellPressed: () {},
                  organizerId: eventData['uid'],
                  currentUserId: currentUserId,
                  favorites: eventData['favorites'],
                  isFavorite: eventData['favorites'].contains(currentUserId),
                  onFollowUpToggled: (_) {},
                  followersCountStream:
                      viewModel.followersCountStream(eventContent.eventId),
                );

        case notificationModel.NotificationType.attending:
          final attendingContent =
              content as notificationModel.AttendingNotificationContent;
          final turnData = await _fetchEventData(attendingContent.turnId, true);
          final userData = await _fetchUserData(turnData['uid']);

          return TurnCardContent(
            turnId: attendingContent.turnId,
            profilePictureUrl: userData['profilePictureUrl'],
            username: userData['username'],
            organizers: turnData['organizers'],
            turnName: turnData['turnName'],
            description: turnData['description'],
            eventDateTime: turnData['eventDateTime'],
            datePublished: turnData['datePublished'],
            turnImageUrl: turnData['turnImageUrl'],
            where: turnData['where'],
            address: turnData['address'],
            moods: turnData['moods'],
            organizerId: turnData['uid'],
            currentUserId: currentUserId,
            favorites: turnData['favorites'],
            isFavorite: turnData['favorites'].contains(currentUserId),
            attendingStatus: 'notAnswered',
            onAttendingStatusChanged: (_) {},
            onSharePressed: () {},
            onSendPressed: () {},
            onFavoritePressed: () {},
            onCommentPressed: () {},
            onAttendingPressed: () {},
            attendingStatusStream: Stream.value('notAnswered'),
            attendingCountStream: Stream.value(0),
          );

        case notificationModel.NotificationType.teamRequest:
        case notificationModel.NotificationType.friendRequest:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestsScreen(
                viewModel: RequestsViewModel(
                  currentUserId: currentUserId,
                ),
              ),
            ),
          );
          return const SizedBox.shrink();

        default:
          throw Exception('Unsupported notification type');
      }
    } catch (e) {
      AppLogger.error('Error building card content: $e');
      return const Center(
        child: Text('Error loading content'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Pas encore de notifications',
          style: CustomTextStyle.body1,
        ),
      );
    }

    return StreamBuilder<int>(
      stream: unreadCountStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur de chargement des notifications',
              style: CustomTextStyle.body1,
            ),
          );
        }

        final unreadCount = snapshot.data ?? 0;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final bool isUnread = index < unreadCount;

            return Column(
              children: [
                Container(
                  color: isUnread
                      ? CustomColor.customDarkGrey
                      : Colors.transparent,
                  child: NotificationCard(
                    notification: notification,
                    onTap: () async {
                      try {
                        if (notification.type ==
                                notificationModel
                                    .NotificationType.teamRequest ||
                            notification.type ==
                                notificationModel
                                    .NotificationType.friendRequest) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestsScreen(
                                viewModel: RequestsViewModel(
                                  currentUserId: currentUserId,
                                ),
                              ),
                            ),
                          );
                        } else {
                          final cardContent =
                              await _buildCardContent(context, notification);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpandedCardScreen(
                                  cardContent: cardContent,
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        AppLogger.error('Error handling notification tap: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error loading content'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                if (index < notifications.length - 1)
                  const Divider(height: 1, color: CustomColor.customDarkGrey),
              ],
            );
          },
        );
      },
    );
  }
}
