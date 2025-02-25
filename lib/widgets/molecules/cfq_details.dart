import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';
import '../../screens/cfq_invitees_screen.dart';
import '../../enums/moods.dart';
import '../../utils/date_time_utils.dart';

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
  final Stream<int>? followersCountStream;
  final DateTime? eventDateTime;
  final DateTime? endDateTime;

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
    this.followersCountStream,
    this.eventDateTime,
    this.endDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isExpanded) const SizedBox(height: 10),
        if (!isExpanded)
          RichText(
            text: TextSpan(
              style: CustomTextStyle.hugeTitle.copyWith(
                fontSize: 26,
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
        isExpanded ? const SizedBox(height: 4) : const SizedBox(height: 12),
        if (moods.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moods
                .map((mood) => MoodChip(
                      icon: _getMoodIcon(mood),
                      label: mood,
                      isSelected: false,
                      onTap: () {},
                    ))
                .toList(),
          ),
        if (moods.isNotEmpty)
          isExpanded ? const SizedBox(height: 12) : const SizedBox(height: 8),
        if (eventDateTime != null) ...[
          Text(
            endDateTime != null
                ? DateTimeUtils.formatDateTimeDisplay(
                    eventDateTime, endDateTime)
                : DateTimeUtils.formatEventDateTime(eventDateTime!),
            style: CustomTextStyle.body1Bold.copyWith(
              fontSize: endDateTime != null ? 12 : 14,
              color: CustomColor.customPurple,
            ),
          ),
          isExpanded ? const SizedBox(height: 10) : const SizedBox(height: 25),
        ],
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CFQInviteesScreen(
                  cfqId: cfqId,
                ),
              ),
            );
          },
          child: StreamBuilder<int>(
            stream: followersCountStream ?? Stream.value(followersCount),
            builder: (context, snapshot) {
              final count = snapshot.data ?? followersCount;
              return RichText(
                text: TextSpan(
                  style: CustomTextStyle.body1,
                  children: [
                    if (count > 0)
                      TextSpan(
                        text: '$count ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    TextSpan(
                      text: count == 0
                          ? CustomString.noFollowersYet
                          : count == 1
                              ? CustomString.onePersonFollows
                              : CustomString.peopleFollow,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        isExpanded ? const SizedBox(height: 30) : const SizedBox(height: 25),
        if (location.isNotEmpty)
          Row(
            children: [
              CustomIcon.eventLocation.copyWith(size: 18),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(location,
                      style: CustomTextStyle.body1.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        if (description.isNotEmpty)
          isExpanded ? const SizedBox(height: 25) : const SizedBox(height: 20),
        if (description.isNotEmpty)
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
    final moodItem = CustomMood.moods.firstWhere(
      (item) => item.label.toLowerCase() == mood.toLowerCase(),
      orElse: () => MoodItem(CustomIcon.otherMood, mood),
    );
    return moodItem.icon;
  }
}
