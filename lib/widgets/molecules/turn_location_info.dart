import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';

class TurnLocationInfo extends StatelessWidget {
  final String where;
  final String address;

  const TurnLocationInfo({
    required this.where,
    required this.address,
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
          text: where,
          color: CustomColor.white70,
          fontSize: CustomFont.fontSize14,
        ),
        const SizedBox(width: 4),
        CustomText(
          text: address,
          color: CustomColor.white54,
          fontSize: CustomFont.fontSize14,
        ),
      ],
    );
  }
}
