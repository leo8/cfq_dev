import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../atoms/buttons/custom_button.dart';
import '../../screens/profile_screen.dart';
import '../../screens/team_details_screen.dart';
import '../atoms/avatars/custom_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/team.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              request.type == RequestType.team
                  ? GestureDetector(
                      onTap: () async {
                        final teamDoc = await FirebaseFirestore.instance
                            .collection('teams')
                            .doc(request.teamId)
                            .get();
                        if (teamDoc.exists && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamDetailsScreen(
                                team: Team.fromSnap(teamDoc),
                                viewMode:
                                    request.status != RequestStatus.accepted,
                              ),
                            ),
                          );
                        }
                      },
                      child: CustomAvatar(
                        imageUrl: request.teamImageUrl ?? '',
                        radius: 25,
                      ),
                    )
                  : ClickableAvatar(
                      userId: request.requesterId,
                      imageUrl: request.requesterProfilePictureUrl,
                      radius: 25,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              userId: request.requesterId,
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: CustomTextStyle.body1,
                        children: [
                          TextSpan(
                            text: request.requesterUsername,
                            style: CustomTextStyle.body1Bold,
                          ),
                          TextSpan(
                            text: _getRequestText(),
                          ),
                          if (request.type == RequestType.team)
                            TextSpan(
                              text: request.teamName,
                              style: CustomTextStyle.body1Bold,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(),
                      style: CustomTextStyle.body2.copyWith(
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTimeAgo(request.timestamp),
                      style: CustomTextStyle.body2.copyWith(
                        color: CustomColor.grey300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.status == RequestStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: CustomString.accept,
                    textStyle: CustomTextStyle.subButton.copyWith(
                      color: CustomColor.customWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    onTap: onAccept,
                    color: CustomColor.customPurple,
                    width: 100,
                    height: 35,
                    padding: 5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    label: CustomString.deny,
                    onTap: onDeny,
                    textStyle: CustomTextStyle.subButton.copyWith(
                      color: CustomColor.customWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    color: CustomColor.customBlack,
                    borderWidth: 0.5,
                    borderColor: CustomColor.customWhite,
                    width: 100,
                    height: 35,
                    padding: 5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getRequestText() {
    if (request.type == RequestType.team) {
      return ' t\'invite à rejoindre ';
    } else {
      return ' souhaite t\'ajouter en ami';
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case RequestStatus.accepted:
        return CustomString.accepted;
      case RequestStatus.denied:
        return CustomString.denied;
      case RequestStatus.pending:
        return CustomString.pending;
    }
  }

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.accepted:
        return CustomColor.green;
      case RequestStatus.denied:
        return CustomColor.red;
      case RequestStatus.pending:
        return CustomColor.grey300;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return CustomString.now;
    }
  }
}
