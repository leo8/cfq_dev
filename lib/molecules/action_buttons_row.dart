import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/buttons/custom_icon_button.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/icons.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onCommentPressed;

  const ActionButtonsRow({
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onCommentPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomIconButton(
          icon: CustomIcon.share,
          onTap: onSharePressed,
          color: CustomColor.white54,
        ),
        CustomIconButton(
          icon: CustomIcon.send,
          onTap: onSendPressed,
          color: CustomColor.white54,
        ),
        CustomIconButton(
          icon: CustomIcon.chatBubbleOutline,
          onTap: onCommentPressed,
          color: CustomColor.white54,
        ),
      ],
    );
  }
}
