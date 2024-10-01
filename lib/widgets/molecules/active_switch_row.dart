import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_switch.dart';

class ActiveSwitchRow extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const ActiveSwitchRow({
    required this.isActive,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomText(
          text: CustomString.off,
          fontSize: CustomFont.fontSize14,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
        const SizedBox(width: 6),
        CustomSwitch(
          value: isActive,
          onChanged: onChanged,
        ),
        const SizedBox(width: 6),
        const CustomText(
          text: CustomString.turn,
          fontSize: CustomFont.fontSize14,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
      ],
    );
  }
}
