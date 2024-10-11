import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/turn_event_details.dart';
import '../molecules/turn_location_info.dart';
import '../molecules/turn_user_info_header.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';

class TurnCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
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

  const TurnCardContent({
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
    required this.onCommentPressed,
    required this.turnImageUrl,
    required this.datePublished,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CustomColor.grey900, CustomColor.grey900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  turnImageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CustomColor.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(
                    text:
                        '${eventDateTime.day} ${DateTimeUtils.getMonthAbbreviation(eventDateTime.month)}',
                    color: CustomColor.white,
                    textStyle: CustomTextStyle.body2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TurnUserInfoHeader(
                  profilePictureUrl: profilePictureUrl,
                  username: username,
                  organizers: organizers,
                  timeInfo: DateTimeUtils.getTimeAgo(datePublished),
                  onAttendingPressed: onAttendingPressed,
                  datePublished: datePublished,
                ),
                const SizedBox(height: 16),
                TurnEventDetails(
                  turnName: turnName,
                  eventDateTime: eventDateTime,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: attendeesCount.toString() +
                      CustomString.space +
                      CustomString.going,
                  textStyle: CustomTextStyle.body2,
                ),
                const SizedBox(height: 8),
                TurnLocationInfo(
                  address: address,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: description,
                  textStyle: CustomTextStyle.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
