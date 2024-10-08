import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/cfq_event_details.dart';
import '../molecules/cfq_location_info.dart';
import '../molecules/cfq_user_info_header.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/fonts.dart';

class CFQCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final String cfqName;
  final String description;
  final DateTime datePublished;
  final String cfqImageUrl;
  final String location;
  final String when;
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
    required this.cfqImageUrl,
    required this.location,
    required this.when,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[900]!, Colors.purple[800]!],
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
                  cfqImageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                  when: when,
                ),
                const SizedBox(height: 8),
                CfqLocationInfo(
                  location: location,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: description,
                  color: CustomColor.white70,
                  fontSize: CustomFont.fontSize14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
