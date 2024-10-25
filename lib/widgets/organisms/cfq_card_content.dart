import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/cfq_header.dart';
import '../molecules/cfq_details.dart';
import '../molecules/cfq_buttons.dart';
import '../../utils/styles/neon_background.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';
import '../../screens/expanded_card_screen.dart';
import '../../utils/logger.dart';

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
  final List<String> followingUp;
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
  final Function(bool) onFollowUpToggled; // New callback
  final bool isExpanded;
  final VoidCallback? onClose;

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
    required this.followingUp,
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
    required this.onFollowUpToggled,
    this.isExpanded = false,
    this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building CFQCardContent, isExpanded: $isExpanded');
    bool isFollowingUp = followingUp.contains(currentUserId);
    int followersCount = followingUp.length;

    Widget content = Container(
      height: isExpanded ? MediaQuery.of(context).size.height : null,
      margin: isExpanded
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        gradient: isExpanded ? null : CustomColor.cfqBackgroundGradient,
        borderRadius:
            isExpanded ? BorderRadius.zero : BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CFQHeader(
            cfqImageUrl: cfqImageUrl,
            when: when,
            isExpanded: isExpanded,
            onClose: isExpanded
                ? () {
                    AppLogger.debug(
                        'onClose callback triggered in CFQCardContent');
                    Navigator.of(context).pop();
                  }
                : null,
          ),
          if (isExpanded)
            Expanded(
              child: NeonBackground(
                child: Padding(
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                      userId: organizerId),
                                            ),
                                          );
                                        },
                                        isActive: false,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            onFollowUpPressed: () =>
                                onFollowUpToggled(!isFollowingUp),
                            isFavorite: isFavorite,
                            isFollowingUp: isFollowingUp,
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
                          cfqId: cfqId,
                          isExpanded: isExpanded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileScreen(
                                              userId: organizerId),
                                        ),
                                      );
                                    },
                                    isActive: false,
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
                        onFollowUpPressed: () =>
                            onFollowUpToggled(!isFollowingUp),
                        isFavorite: isFavorite,
                        isFollowingUp: isFollowingUp,
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
                      cfqId: cfqId,
                      isExpanded: isExpanded,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (!isExpanded) {
      content = GestureDetector(
        onTap: () {
          AppLogger.debug('CFQCardContent tapped, navigating to expanded view');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExpandedCardScreen(
                cardContent: this,
              ),
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }
}
