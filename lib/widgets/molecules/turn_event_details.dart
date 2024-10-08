import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/date_time_utils.dart';

class TurnEventDetails extends StatelessWidget {
  final String turnName;
  final DateTime eventDateTime;

  const TurnEventDetails({
    required this.turnName,
    required this.eventDateTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: turnName,
          color: CustomColor.white,
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: '${DateTimeUtils.formatEventTime(eventDateTime)}',
          color: CustomColor.pinkAccent,
          fontWeight: CustomFont.fontWeight500,
          fontSize: CustomFont.fontSize14,
        ),
      ],
    );
  }
}
