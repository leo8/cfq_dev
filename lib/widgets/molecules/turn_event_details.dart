import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/icons.dart';

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
    String formattedDateTime =
        '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year} | ${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';
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
          color: CustomColor.white,
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
