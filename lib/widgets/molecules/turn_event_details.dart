import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';

class TurnEventDetails extends StatelessWidget {
  final String where; // The general location (e.g., "at home")
  final String turnName; // The name of the TURN event
  final DateTime eventDateTime; // The date and time of the TURN event

  const TurnEventDetails({
    required this.where,
    required this.turnName,
    required this.eventDateTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date and time for display
    String formattedDateTime =
        '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year} | ${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
      children: [
        // Display location information
        Row(
          children: [
            const Icon(
              CustomIcon.home, // Location icon
              color: CustomColor.white54, // Subtle color for icon
              size: 20,
            ),
            const SizedBox(width: 4),
            CustomText(
              text: where, // The location text (e.g., "at home")
              color: CustomColor.white54, // Subtle color for text
              fontSize: CustomFont.fontSize14,
            ),
          ],
        ),
        const SizedBox(height: 8), // Space between location and event name
        // Display the TURN event name
        CustomText(
          text: turnName, // The name of the TURN event
          color: CustomColor.white, // Bold color for the event name
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
        const SizedBox(height: 8), // Space between event name and date/time
        // Display the event's date and time
        CustomText(
          text: formattedDateTime, // The formatted date and time
          color: CustomColor.pinkAccent, // Accent color for the date/time
          fontWeight: CustomFont.fontWeight500,
          fontSize: CustomFont.fontSize14,
        ),
      ],
    );
  }
}
