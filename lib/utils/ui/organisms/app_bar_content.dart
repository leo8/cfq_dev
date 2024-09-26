import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/ui/molecules/custom_search_bar.dart';
import '../../gen/colors.dart';
import '../../gen/icons.dart';
import '../../gen/string.dart';
import '../atoms/buttons/custom_icon_button.dart';

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
