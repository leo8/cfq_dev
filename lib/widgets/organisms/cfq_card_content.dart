import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/cfq_header.dart';
import '../molecules/cfq_details.dart';
import '../molecules/cfq_buttons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';

class CFQCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final List<String> moods; // New field for moods
  final String cfqName;
  final String description;
  final DateTime datePublished;
  final String cfqImageUrl;
  final String location;
  final String when;
  final int followersCount; // New field for followers count
  final String cfqId;
  final String organizerId;
  final String currentUserId;
  final List favorites;
  final VoidCallback onFollowPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onFavoritePressed; // New callback for favorite button
  final VoidCallback onBellPressed; // New callback for bell button
  final bool isFavorite;

  const CFQCardContent({
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.moods,
    required this.cfqName,
    required this.description,
    required this.datePublished,
    required this.cfqImageUrl,
    required this.location,
    required this.when,
    required this.followersCount,
    required this.onFollowPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.onBellPressed,
    required this.cfqId,
    required this.organizerId,
    required this.currentUserId,
    required this.favorites,
    required this.isFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        gradient: CustomColor.cfqBackgroundGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CFQHeader(
            cfqImageUrl: cfqImageUrl,
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
                                  '$username . ${DateTimeUtils.getTimeAgo(datePublished)}',
                                  style: CustomTextStyle.body1
                                      .copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    CFQButtons(
                      onSendPressed: onSendPressed,
                      onFavoritePressed: onFavoritePressed,
                      onFollowUpPressed: onBellPressed,
                      isFavorite: isFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: CFQDetails(
                    profilePictureUrl: profilePictureUrl,
                    username: username,
                    datePublished: datePublished,
                    cfqName: cfqName,
                    moods: moods,
                    when: when,
                    followersCount: followersCount,
                    location: location,
                    description: description,
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
