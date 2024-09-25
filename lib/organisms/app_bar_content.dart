import 'package:cfq_dev/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/molecules/custom_search_bar.dart';
import 'package:cfq_dev/atoms/buttons/custom_icon_button.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/icons.dart';

class AppBarContent extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onNotificationPressed;

  const AppBarContent({
    required this.searchController,
    required this.onNotificationPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBar(
            controller: searchController,
            hintText: CustomString.searchUsers,
          ),
        ),
        const SizedBox(width: 10),
        CustomIconButton(
          icon: CustomIcon.notifications,
          onTap: onNotificationPressed,
          color: CustomColor.primaryColor,
        ),
      ],
    );
  }
}
