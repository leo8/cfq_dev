import 'package:flutter/material.dart';
import 'package:cfq_dev/molecules/turn_user_info_header.dart';
import 'package:cfq_dev/molecules/turn_event_details.dart';
import 'package:cfq_dev/molecules/description_section.dart';
import 'package:cfq_dev/molecules/turn_location_info.dart';
import 'package:cfq_dev/molecules/action_buttons_row.dart';
import 'package:cfq_dev/utils/colors.dart';

class TurnCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final String timeInfo;
  final String turnName;
  final String description;
  final DateTime eventDateTime;
  final String where;
  final String address;
  final VoidCallback onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onCommentPressed;

  const TurnCardContent({
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.timeInfo,
    required this.turnName,
    required this.description,
    required this.eventDateTime,
    required this.where,
    required this.address,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onCommentPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0551),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColor.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TurnUserInfoHeader(
            profilePictureUrl: profilePictureUrl,
            username: username,
            organizers: organizers,
            timeInfo: timeInfo,
            onAttendingPressed: onAttendingPressed,
          ),
          const SizedBox(height: 16),
          TurnEventDetails(
            where: where,
            turnName: turnName,
            eventDateTime: eventDateTime,
          ),
          const SizedBox(height: 8),
          DescriptionSection(
            description: description,
          ),
          const SizedBox(height: 16),
          TurnLocationInfo(
            where: where,
            address: address,
          ),
          const SizedBox(height: 16),
          ActionButtonsRow(
            onSharePressed: onSharePressed,
            onSendPressed: onSendPressed,
            onCommentPressed: onCommentPressed,
          ),
        ],
      ),
    );
  }
}
