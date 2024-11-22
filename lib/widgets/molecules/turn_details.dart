import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';
import '../atoms/chips/mood_chip.dart';
import '../../screens/turn_invitees_screen.dart';
import '../../enums/moods.dart';

class TurnDetails extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final DateTime datePublished;
  final String turnName;
  final List<String> moods;
  final DateTime eventDateTime;
  final DateTime? endDateTime;
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
    this.endDateTime,
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
        if (!isExpanded) const SizedBox(height: 10),
        if (!isExpanded)
          Text(turnName,
              style: CustomTextStyle.hugeTitle.copyWith(
                fontSize: 26,
                letterSpacing: 1.4,
              )),
        isExpanded
            ? const SizedBox(
                height: 4,
              )
            : const SizedBox(height: 12),
        if (!moods.isEmpty)
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
        if (!moods.isEmpty)
          isExpanded
              ? const SizedBox(
                  height: 20,
                )
              : const SizedBox(height: 15),
        Text(
          endDateTime != null
              ? DateTimeUtils.formatDateTimeDisplay(eventDateTime, endDateTime)
              : DateTimeUtils.formatEventDateTime(eventDateTime),
          style: CustomTextStyle.body1Bold.copyWith(
            fontSize: endDateTime != null ? 12 : 14,
            color: CustomColor.customPurple,
          ),
        ),
        isExpanded
            ? const SizedBox(
                height: 30,
              )
            : const SizedBox(height: 25),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' ${_getAttendeesText()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        isExpanded
            ? const SizedBox(
                height: 30,
              )
            : const SizedBox(height: 25),
        isExpanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIcon.eventLocation.copyWith(size: 12),
                      const SizedBox(width: 12),
                      Text(
                        where,
                        style: CustomTextStyle.body1.copyWith(fontSize: 12),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    address,
                    style: CustomTextStyle.body1.copyWith(fontSize: 12),
                    maxLines: 30,
                  ),
                ],
              )
            : Row(
                children: [
                  CustomIcon.eventLocation.copyWith(size: 18),
                  const SizedBox(width: 4),
                  Text(where,
                      style: CustomTextStyle.body1.copyWith(fontSize: 12)),
                  if (address.isNotEmpty)
                    Text(' | ',
                        style: CustomTextStyle.body1.copyWith(fontSize: 12)),
                  if (address.isNotEmpty)
                    Expanded(
                        child: Text(address,
                            style: CustomTextStyle.body1.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                ],
              ),
        if (description.isNotEmpty)
          isExpanded
              ? const SizedBox(
                  height: 25,
                )
              : const SizedBox(height: 20),
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
