import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';

class CfqLocationInfo extends StatelessWidget {
  final String location; // The location of the CFQ event

  const CfqLocationInfo({
    required this.location, // Location passed as a required parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Location icon
        const Icon(
          CustomIcon.locationOn,
          color: CustomColor.white54,
          size: 20,
        ),
        const SizedBox(width: 4), // Space between icon and location text
        // Location text
        CustomText(
          text: location, // Display the location
          color: CustomColor.white70, // Text color for the location
        ),
      ],
    );
  }
}
