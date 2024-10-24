import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';
import '../../screens/cfq_invitees_screen.dart';

class CFQDetails extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final DateTime datePublished;
  final String cfqName;
  final List<String> moods;
  final String when;
  final int followersCount;
  final String location;
  final String description;
  final String cfqId;
  final bool isExpanded;

  const CFQDetails({
    Key? key,
    required this.profilePictureUrl,
    required this.username,
    required this.datePublished,
    required this.cfqName,
    required this.moods,
    required this.when,
    required this.followersCount,
    required this.location,
    required this.description,
    required this.cfqId,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isExpanded)
          RichText(
            text: TextSpan(
              style: CustomTextStyle.hugeTitle.copyWith(
                fontSize: 28,
                letterSpacing: 1.4,
              ),
              children: [
                const TextSpan(text: 'ÇFQ '),
                TextSpan(
                  text: when.toUpperCase(),
                  style: const TextStyle(color: CustomColor.customPurple),
                ),
                const TextSpan(text: ' ?'),
              ],
            ),
          ),
        isExpanded
            ? const SizedBox(
                height: 4,
              )
            : const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: moods
              .map((mood) => MoodChip(
                    icon: _getMoodIcon(mood),
                    label: mood,
                    isSelected: false,
                    onTap: () {},
                  ))
              .toList(),
        ),
        isExpanded
            ? const SizedBox(
                height: 35,
              )
            : const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CFQInviteesScreen(cfqId: cfqId)),
            );
          },
          child: RichText(
            text: TextSpan(
              style: CustomTextStyle.body1,
              children: [
                TextSpan(
                  text: _getFollowersCount(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${_getFollowersText()}'),
              ],
            ),
          ),
        ),
        isExpanded
            ? const SizedBox(
                height: 35,
              )
            : const SizedBox(height: 20),
        Text(location, style: CustomTextStyle.body1),
        isExpanded
            ? const SizedBox(
                height: 15,
              )
            : const SizedBox(height: 8),
        Text(
          description,
          style: CustomTextStyle.body1,
          maxLines: isExpanded ? 50 : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  CustomIcon _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'street':
        return CustomIcon.streetMood;
      case 'home':
        return CustomIcon.homeMood;
      case 'chill':
        return CustomIcon.chillMood;
      case 'diner':
        return CustomIcon.dinerMood;
      case 'bar':
        return CustomIcon.barMood;
      case 'turn':
        return CustomIcon.turnMood;
      case 'club':
        return CustomIcon.clubMood;
      case 'before':
        return CustomIcon.beforeMood;
      case 'after':
        return CustomIcon.afterMood;
      default:
        return CustomIcon.turnMood; // Default icon
    }
  }

  String _getFollowersCount() {
    if (followersCount == 0) return '';
    return '$followersCount';
  }

  String _getFollowersText() {
    if (followersCount == 0) {
      return CustomString.noFollowersYet;
    } else if (followersCount == 1) {
      return CustomString.onePersonFollows;
    } else {
      return CustomString.peopleFollow;
    }
  }
}
