import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/icons.dart';

class CfqLocationInfo extends StatelessWidget {
  final String location;

  const CfqLocationInfo({
    required this.location,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          CustomIcon.locationOn,
          color: CustomColor.white54,
          size: 20,
        ),
        const SizedBox(width: 4),
        CustomText(
          text: location,
          color: CustomColor.white70,
        ),
      ],
    );
  }
}
