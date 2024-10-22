import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/turn_header.dart';
import '../molecules/turn_details.dart';
import '../molecules/turn_buttons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';

class TurnCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final List<String> moods;
  final String turnName;
  final String description;
  final DateTime eventDateTime;
  final DateTime datePublished;
  final String turnImageUrl;
  final String where;
  final String address;
  final int attendeesCount;
  final VoidCallback onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onFavoritePressed;
  final String turnId;
  final String organizerId;
  final String currentUserId;
  final List favorites;
  final bool isFavorite;
  final String attendingStatus;
  final Function(String) onAttendingStatusChanged;
  final Stream<String> attendingStatusStream;
  final Stream<int> attendingCountStream;

  const TurnCardContent({
    required this.attendingStatus,
    required this.onAttendingStatusChanged,
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.turnName,
    required this.description,
    required this.eventDateTime,
    required this.where,
    required this.address,
    required this.attendeesCount,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.onCommentPressed,
    required this.turnImageUrl,
    required this.datePublished,
    required this.moods,
    required this.turnId,
    required this.organizerId,
    required this.currentUserId,
    required this.favorites,
    required this.isFavorite,
    required this.attendingStatusStream,
    required this.attendingCountStream,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        gradient: CustomColor.turnBackgroundGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TurnHeader(
            turnImageUrl: turnImageUrl,
            eventDateTime: eventDateTime,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          currentUserId != organizerId
                              ? ClickableAvatar(
                                  userId: organizerId,
                                  imageUrl: profilePictureUrl,
                                  onTap: () {
                                    // Navigate to friend's profile
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen(userId: organizerId),
                                      ),
                                    );
                                  },
                                  isActive: false, // Add isActive
                                  radius: 28,
                                )
                              : ClickableAvatar(
                                  userId: organizerId,
                                  imageUrl: profilePictureUrl,
                                  onTap: () {},
                                ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${username} . ${DateTimeUtils.getTimeAgo(datePublished)}',
                                    style: CustomTextStyle.body1
                                        .copyWith(fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TurnButtons(
                      onAttendingPressed: onAttendingStatusChanged,
                      onSharePressed: onSharePressed,
                      onSendPressed: onSendPressed,
                      onFavoritePressed: onFavoritePressed,
                      isFavorite: isFavorite,
                      attendingStatusStream: attendingStatusStream,
                      attendingStatus: attendingStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: StreamBuilder<int>(
                    stream: attendingCountStream,
                    builder: (context, snapshot) {
                      final attendingCount = snapshot.data ?? 0;
                      return TurnDetails(
                        profilePictureUrl: profilePictureUrl,
                        username: username,
                        datePublished: datePublished,
                        turnName: turnName,
                        moods: moods,
                        eventDateTime: eventDateTime,
                        attendeesCount: attendingCount,
                        where: where,
                        address: address,
                        description: description,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
