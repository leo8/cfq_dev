import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../atoms/buttons/custom_icon_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback
      onSharePressed; // Callback for when the share button is pressed
  final VoidCallback
      onSendPressed; // Callback for when the send button is pressed
  final VoidCallback
      onCommentPressed; // Callback for when the comment button is pressed

  const ActionButtonsRow({
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onCommentPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
      children: [
        // Share button
        CustomIconButton(
          icon: CustomIcon.share, // Icon for share action
          onTap: onSharePressed, // Execute callback when tapped
          color: CustomColor.white54, // Set icon color
        ),
        // Send button
        CustomIconButton(
          icon: CustomIcon.send, // Icon for send action
          onTap: onSendPressed, // Execute callback when tapped
          color: CustomColor.white54, // Set icon color
        ),
        // Comment button
        CustomIconButton(
          icon: CustomIcon.chatBubbleOutline, // Icon for comment action
          onTap: onCommentPressed, // Execute callback when tapped
          color: CustomColor.white54, // Set icon color
        ),
      ],
    );
  }
}
