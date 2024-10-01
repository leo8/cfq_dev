import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_switch.dart';

class ActiveSwitchRow extends StatelessWidget {
  final bool isActive; // Boolean to determine the switch's state (on/off)
  final ValueChanged<bool>
      onChanged; // Callback function for when the switch is toggled

  const ActiveSwitchRow({
    required this.isActive,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the row
      children: [
        // "Off" label text on the left side of the switch
        const CustomText(
          text: CustomString.off, // Text for the "off" label
          fontSize: CustomFont.fontSize14,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
        const SizedBox(width: 6), // Spacing between "Off" and the switch
        // The switch itself
        CustomSwitch(
          value: isActive, // Current state of the switch (active or not)
          onChanged:
              onChanged, // Function to be called when the switch is toggled
        ),
        const SizedBox(
            width: 6), // Spacing between the switch and the "On" label
        // "On" label text on the right side of the switch
        const CustomText(
          text: CustomString.turn, // Text for the "on" label
          fontSize: CustomFont.fontSize14,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
      ],
    );
  }
}
