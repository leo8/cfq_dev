import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';

class TurnButtons extends StatelessWidget {
  final VoidCallback onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;

  const TurnButtons({
    Key? key,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.customDarkGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.circle), // Replace with actual icon
            onPressed: onAttendingPressed,
            color: CustomColor.customWhite,
          ),
          IconButton(
            icon: CustomIcon.favorite,
            onPressed: onSharePressed,
            color: CustomColor.customWhite,
          ),
          IconButton(
            icon: CustomIcon.eventConversation,
            onPressed: onSendPressed,
            color: CustomColor.customWhite,
          ),
        ],
      ),
    );
  }
}
