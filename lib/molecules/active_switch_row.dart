import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/atoms/buttons/custom_switch.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/string.dart';

class ActiveSwitchRow extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const ActiveSwitchRow({
    required this.isActive,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomText(
          text: CustomString.off,
          fontSize: CustomFont.fontSize14,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.primaryColor,
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
          color: CustomColor.primaryColor,
        ),
      ],
    );
  }
}
