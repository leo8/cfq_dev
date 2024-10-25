import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';
import '../../screens/turn_invitees_screen.dart';

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
  final String turnId;
  final bool isExpanded;

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
    required this.turnId,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isExpanded)
          Text(turnName,
              style: CustomTextStyle.hugeTitle.copyWith(
                fontSize: 28,
                letterSpacing: 1.4,
              )),
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
                height: 20,
              )
            : const SizedBox(height: 15),
        Text(DateTimeUtils.formatEventDateTime(eventDateTime),
            style: CustomTextStyle.title3.copyWith(
                color: CustomColor.customPurple, fontWeight: FontWeight.bold)),
        isExpanded
            ? const SizedBox(
                height: 15,
              )
            : const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TurnInviteesScreen(
                        turnId: turnId,
                      )),
            );
          },
          child: RichText(
            text: TextSpan(
              style: CustomTextStyle.body1,
              children: [
                TextSpan(
                  text: _getAttendeesCount(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${_getAttendeesText()}'),
              ],
            ),
          ),
        ),
        isExpanded
            ? const SizedBox(
                height: 35,
              )
            : const SizedBox(height: 20),
        isExpanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    where,
                    style: CustomTextStyle.body1,
                    maxLines: 3,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    address,
                    style: CustomTextStyle.body1,
                    maxLines: 30,
                  ),
                ],
              )
            : Row(
                children: [
                  Text(where, style: CustomTextStyle.body1),
                  Text(' | ', style: CustomTextStyle.body1),
                  Expanded(
                      child: Text(address,
                          style: CustomTextStyle.body1,
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
        isExpanded
            ? const SizedBox(
                height: 35,
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

  String _getAttendeesCount() {
    if (attendeesCount == 0) return '';
    return '$attendeesCount';
  }

  String _getAttendeesText() {
    if (attendeesCount == 0) {
      return CustomString.noAttendeesYet;
    } else if (attendeesCount == 1) {
      return CustomString.onePersonAttending;
    } else {
      return CustomString.peopleAttending;
    }
  }
}
