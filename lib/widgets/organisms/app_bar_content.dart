import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/molecules/custom_search_bar.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_icon_button.dart';

class AppBarContent extends StatelessWidget {
  final TextEditingController
      searchController; // Controller for the search input
  final VoidCallback
      onNotificationPressed; // Callback for notification button action

  const AppBarContent({
    required this.searchController, // Requires a search controller
    required this.onNotificationPressed, // Requires a function to handle notification presses
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBar(
            controller: searchController, // Assigning the search controller
            hintText:
                CustomString.searchUsers, // Placeholder text for the search bar
          ),
        ),
        const SizedBox(
            width: 10), // Space between the search bar and notification button
        CustomIconButton(
          icon: CustomIcon.notifications, // Notification icon
          onTap:
              onNotificationPressed, // Action to perform when the notification button is pressed
          color: CustomColor.white, // Color for the icon
        ),
      ],
    );
  }
}
