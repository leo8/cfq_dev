import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/molecules/cfq_user_info_header.dart';
import '../../utils/styles/colors.dart';
import '../molecules/action_buttons_row.dart';
import '../molecules/cfq_event_details.dart';
import '../molecules/cfq_location_info.dart';
import '../molecules/description_section.dart';

class CFQCardContent extends StatelessWidget {
  final String profilePictureUrl; // User's profile picture URL
  final String username; // User's name
  final List<String> organizers; // List of event organizers
  final String cfqName; // CFQ event name
  final String description; // CFQ event description
  final DateTime datePublished; // Date when the CFQ was published
  final String location; // Location of the CFQ event
  final VoidCallback onFollowPressed; // Callback for follow button
  final VoidCallback onSharePressed; // Callback for share button
  final VoidCallback onSendPressed; // Callback for send button
  final VoidCallback onCommentPressed; // Callback for comment button

  const CFQCardContent({
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.cfqName,
    required this.description,
    required this.datePublished,
    required this.location,
    required this.onFollowPressed,
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
        color: const Color(0xFF1A0551), // Card background color
        borderRadius: BorderRadius.circular(16), // Rounded corners
        border: Border.all(color: CustomColor.white24), // Border color
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          CfqUserInfoHeader(
            profilePictureUrl: profilePictureUrl, // User's profile picture
            username: username, // User's name
            organizers: organizers, // List of event organizers
            datePublished: datePublished, // Date published
            onFollowPressed: onFollowPressed, // Follow button action
          ),
          const SizedBox(height: 16), // Space between sections
          CfqEventDetails(
            cfqName: cfqName, // Name of the CFQ event
          ),
          const SizedBox(height: 8), // Space between sections
          DescriptionSection(
            description: description, // Description of the CFQ
          ),
          const SizedBox(height: 16), // Space between sections
          CfqLocationInfo(
            location: location, // Location of the CFQ event
          ),
          const SizedBox(height: 16), // Space between sections
          ActionButtonsRow(
            onSharePressed: onSharePressed, // Share button action
            onSendPressed: onSendPressed, // Send button action
            onCommentPressed: onCommentPressed, // Comment button action
          ),
        ],
      ),
    );
  }
}
