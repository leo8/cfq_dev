import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/icons.dart';

class TurnEventDetails extends StatelessWidget {
  final String where;
  final String turnName;
  final DateTime eventDateTime;

  const TurnEventDetails({
    required this.where,
    required this.turnName,
    required this.eventDateTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year} | ${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CustomIcon.home,
              color: CustomColor.white54,
              size: 20,
            ),
            const SizedBox(width: 4),
            CustomText(
              text: where,
              color: CustomColor.white54,
              fontSize: CustomFont.fontSize14,
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomText(
          text: turnName,
          color: CustomColor.primaryColor,
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: formattedDateTime,
          color: CustomColor.pinkAccent,
          fontWeight: CustomFont.fontWeight500,
          fontSize: CustomFont.fontSize14,
        ),
      ],
    );
  }
}
