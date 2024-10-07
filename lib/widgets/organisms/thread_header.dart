import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../molecules/custom_search_bar.dart';
import '../atoms/buttons/custom_icon_button.dart';

class ThreadHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onNotificationTap;
  final VoidCallback onMessageTap;

  const ThreadHeader({
    Key? key,
    required this.searchController,
    required this.onNotificationTap,
    required this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBar(
            controller: searchController,
          ),
        ),
        const SizedBox(width: 10),
        CustomIconButton(
          icon: CustomIcon.notifications,
          color: CustomColor.white,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 10),
        CustomIconButton(
          icon: Icons.message,
          color: CustomColor.white,
          onTap: onMessageTap,
        ),
      ],
    );
  }
}
