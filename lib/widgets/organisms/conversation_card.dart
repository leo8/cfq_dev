import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;

  const ConversationCard({Key? key, required this.conversation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColor.customDarkGrey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(conversation.imageUrl),
              radius: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: CustomTextStyle.body1Bold,
                  ),
                  Text(
                    '${conversation.lastSenderUsername}: ${conversation.lastMessageContent}',
                    style:
                        CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              DateTimeUtils.getTimeAgo(conversation.lastMessageTimestamp),
              style: CustomTextStyle.body2.copyWith(color: CustomColor.grey),
            ),
          ],
        ),
      ),
    );
  }
}
