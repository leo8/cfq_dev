import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';

class TurnLocationInfo extends StatelessWidget {
  final String where; // General location (e.g., "at home", "at a park")
  final String address; // Specific address of the event

  const TurnLocationInfo({
    required this.where,
    required this.address,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Location icon
        const Icon(
          CustomIcon.locationOn,
          color: CustomColor.white54, // Light color for the icon
          size: 20, // Icon size
        ),
        const SizedBox(width: 4), // Spacing between the icon and text
        // Display the general location
        CustomText(
          text: where, // General location (e.g., "at home")
          color: CustomColor.white70, // Slightly lighter color
          fontSize: CustomFont.fontSize14, // Text size
        ),
        const SizedBox(width: 4), // Spacing between the location and address
        // Display the specific address
        CustomText(
          text: address, // Specific address (e.g., "123 Main St")
          color: CustomColor.white54, // Lighter color for less emphasis
          fontSize: CustomFont.fontSize14, // Text size
        ),
      ],
    );
  }
}
