import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../../utils/date_time_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final int unreadMessagesCount;
  final String currentUserUsername;

  const ConversationCard({
    Key? key,
    required this.conversation,
    required this.unreadMessagesCount,
    required this.currentUserUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (unreadMessagesCount >= 1)
          ? CustomColor.customDarkGrey
          : CustomColor.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: conversation.imageUrl.isNotEmpty
              ? NetworkImage(conversation.imageUrl)
              : null,
          radius: 25,
          child: conversation.imageUrl.isEmpty
              ? SvgPicture.asset(
                  conversation.name.contains('ÇFQ')
                      ? 'assets/images/cfq_button.svg'
                      : 'assets/images/turn_button.svg',
                )
              : null,
        ),
        title: Text(
          conversation.name,
          style: CustomTextStyle.body1Bold,
        ),
        subtitle: unreadMessagesCount > 0
            ? Text(
                "${unreadMessagesCount} ${unreadMessagesCount == 1 ? CustomString.newSingle : CustomString.newPlural} ${unreadMessagesCount == 1 ? CustomString.message : CustomString.messages}",
                style: CustomTextStyle.miniBody.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CustomColor.customWhite,
                ),
              )
            : Text(
                conversation.lastMessageContent.isEmpty
                    ? CustomString.noMessagesYet
                    : '${_getLastSenderDisplay()}: ${conversation.lastMessageContent}',
                style: CustomTextStyle.miniBody,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Text(
          DateTimeUtils.getTimeAgo(conversation.lastMessageTimestamp),
          style: CustomTextStyle.body2.copyWith(color: CustomColor.grey),
        ),
      ),
    );
  }

  String _getLastSenderDisplay() {
    return conversation.lastSenderUsername == currentUserUsername
        ? CustomString.you
        : conversation.lastSenderUsername;
  }
}
