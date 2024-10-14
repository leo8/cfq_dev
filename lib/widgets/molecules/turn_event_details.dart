import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';
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
          textStyle: CustomTextStyle.title3,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: DateTimeUtils.formatEventTime(eventDateTime),
          textStyle: CustomTextStyle.getColoredTextStyle(
              CustomTextStyle.miniBody, CustomColor.pinkAccent),
        ),
      ],
    );
  }
}
