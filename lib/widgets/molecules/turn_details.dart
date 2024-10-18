import 'package:flutter/material.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';

class TurnDetails extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final DateTime datePublished;
  final String turnName;
  final List<String> moods;
  final DateTime eventDateTime;
  final int attendeesCount;
  final String where;
  final String address;
  final String description;

  const TurnDetails({
    Key? key,
    required this.profilePictureUrl,
    required this.username,
    required this.datePublished,
    required this.turnName,
    required this.moods,
    required this.eventDateTime,
    required this.attendeesCount,
    required this.where,
    required this.address,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(turnName,
            style: CustomTextStyle.hugeTitle.copyWith(
              fontSize: 28,
              letterSpacing: 1.4,
            )),
        const SizedBox(height: 8),
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
        Text(DateTimeUtils.formatEventDateTime(eventDateTime),
            style: CustomTextStyle.title3.copyWith(
                color: CustomColor.customPurple, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$attendeesCount ${CustomString.going}',
            style: CustomTextStyle.body1),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(where, style: CustomTextStyle.body1),
            Text(' | ', style: CustomTextStyle.body1),
            Expanded(
                child: Text(address,
                    style: CustomTextStyle.body1,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
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
}
