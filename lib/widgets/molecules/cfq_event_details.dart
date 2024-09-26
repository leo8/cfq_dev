import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';

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
        const Row(
          children: [
            Icon(
              CustomIcon.event,
              color: CustomColor.white54,
              size: 20,
            ),
            SizedBox(width: 4),
            CustomText(
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
