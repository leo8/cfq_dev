import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';

class CfqEventDetails extends StatelessWidget {
  final String cfqName; // CFQ event name to be displayed

  const CfqEventDetails({
    required this.cfqName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
      children: [
        // Row for event icon and CFQ label
        const Row(
          children: [
            // Event icon
            Icon(
              CustomIcon.event,
              color: CustomColor.white54,
              size: 20,
            ),
            SizedBox(width: 4), // Small space between icon and text
            // Text label "CFQ"
            CustomText(
              text: CustomString.cfq,
              color: CustomColor.white54,
              fontSize: CustomFont.fontSize14,
            ),
          ],
        ),
        const SizedBox(height: 8), // Space between the label and event name
        // CFQ event name
        CustomText(
          text: cfqName, // The name of the CFQ event passed as a parameter
          color: CustomColor.white,
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
      ],
    );
  }
}
