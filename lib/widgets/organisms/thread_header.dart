import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../atoms/buttons/custom_icon_button.dart';

class ThreadHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMessageTap;

  const ThreadHeader({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconButton(
          icon: CustomIcon.search,
          color: CustomColor.customWhite,
          onTap: onSearchTap,
        ),
        const Spacer(),
        CustomIconButton(
          icon: CustomIcon.notifications,
          color: CustomColor.customWhite,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 10),
        CustomIconButton(
          icon: CustomIcon.inbox,
          color: CustomColor.customWhite,
          onTap: onMessageTap,
        ),
      ],
    );
  }
}
