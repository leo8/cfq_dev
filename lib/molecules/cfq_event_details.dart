import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:cfq_dev/utils/string.dart';

class CfqEventDetails extends StatelessWidget {
  final String cfqName;

  const CfqEventDetails({
    required this.cfqName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CustomIcon.event,
              color: CustomColor.white54,
              size: 20,
            ),
            const SizedBox(width: 4),
            const CustomText(
              text: CustomString.cfq,
              color: CustomColor.white54,
              fontSize: CustomFont.fontSize14,
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomText(
          text: cfqName,
          color: CustomColor.primaryColor,
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
      ],
    );
  }
}
