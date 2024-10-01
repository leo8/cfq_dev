import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart'; // Import color styles
import '../molecules/action_buttons_row.dart'; // Import action buttons row
import '../molecules/description_section.dart'; // Import description section
import '../molecules/turn_event_details.dart'; // Import turn event details
import '../molecules/turn_location_info.dart'; // Import turn location info
import '../molecules/turn_user_info_header.dart'; // Import user info header

class TurnCardContent extends StatelessWidget {
  final String profilePictureUrl; // URL of the user's profile picture
  final String username; // Username of the user
  final List<String> organizers; // List of event organizers
  final String timeInfo; // Information about event timing
  final String turnName; // Name of the turn event
  final String description; // Description of the turn event
  final DateTime eventDateTime; // Date and time of the event
  final String where; // Location of the event
  final String address; // Address of the event
  final VoidCallback onAttendingPressed; // Callback for attending button
  final VoidCallback onSharePressed; // Callback for share button
  final VoidCallback onSendPressed; // Callback for send button
  final VoidCallback onCommentPressed; // Callback for comment button

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
      margin: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 16), // Margin around the card
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: const Color(0xFF1A0551), // Background color of the card
        borderRadius: BorderRadius.circular(16), // Rounded corners for the card
        border:
            Border.all(color: CustomColor.white24), // Border color of the card
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          // User info header section
          TurnUserInfoHeader(
            profilePictureUrl: profilePictureUrl, // Pass profile picture URL
            username: username, // Pass username
            organizers: organizers, // Pass list of organizers
            timeInfo: timeInfo, // Pass time info
            onAttendingPressed:
                onAttendingPressed, // Action for attending button
          ),
          const SizedBox(height: 16), // Space between sections
          // Event details section
          TurnEventDetails(
            where: where, // Pass event location
            turnName: turnName, // Pass turn name
            eventDateTime: eventDateTime, // Pass event date and time
          ),
          const SizedBox(height: 8), // Space between sections
          // Description section
          DescriptionSection(
            description: description, // Pass event description
          ),
          const SizedBox(height: 16), // Space between sections
          // Location information section
          TurnLocationInfo(
            where: where, // Pass location
            address: address, // Pass address
          ),
          const SizedBox(height: 16), // Space between sections
          // Action buttons row
          ActionButtonsRow(
            onSharePressed: onSharePressed, // Action for share button
            onSendPressed: onSendPressed, // Action for send button
            onCommentPressed: onCommentPressed, // Action for comment button
          ),
        ],
      ),
    );
  }
}
