import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 20),
        RichText(
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
        const SizedBox(height: 20),
        Text(location, style: CustomTextStyle.body1),
        const SizedBox(height: 8),
        Text(
          description,
          style: CustomTextStyle.body1,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
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
