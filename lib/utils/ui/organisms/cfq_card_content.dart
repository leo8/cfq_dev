import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/ui/molecules/cfq_user_info_header.dart';
import '../../gen/colors.dart';
import '../molecules/action_buttons_row.dart';
import '../molecules/cfq_event_details.dart';
import '../molecules/cfq_location_info.dart';
import '../molecules/description_section.dart';

class CFQCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final String cfqName;
  final String description;
  final DateTime datePublished;
  final String location;
  final VoidCallback onFollowPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onCommentPressed;

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
          CfqUserInfoHeader(
            profilePictureUrl: profilePictureUrl,
            username: username,
            organizers: organizers,
            datePublished: datePublished,
            onFollowPressed: onFollowPressed,
          ),
          const SizedBox(height: 16),
          CfqEventDetails(
            cfqName: cfqName,
          ),
          const SizedBox(height: 8),
          DescriptionSection(
            description: description,
          ),
          const SizedBox(height: 16),
          CfqLocationInfo(
            location: location,
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
