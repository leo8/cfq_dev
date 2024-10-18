import 'package:flutter/material.dart';
import '../../utils/styles/icons.dart';

class CFQButtons extends StatelessWidget {
  final VoidCallback onSendPressed;
  final VoidCallback onFavoritePressed;
  final VoidCallback onBellPressed;

  const CFQButtons({
    Key? key,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.onBellPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: CustomIcon.eventConversation,
          onPressed: onSendPressed,
        ),
        IconButton(
          icon: CustomIcon.favorite,
          onPressed: onFavoritePressed,
        ),
        IconButton(
          icon: CustomIcon.followUp,
          onPressed: onBellPressed,
        ),
      ],
    );
  }
}
