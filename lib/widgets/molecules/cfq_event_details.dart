import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/string.dart';
import '../../../utils/styles/text_styles.dart';

class CfqEventDetails extends StatelessWidget {
  final String cfqName;
  final String when;

  const CfqEventDetails({
    required this.cfqName,
    required this.when,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: cfqName,
          textStyle: CustomTextStyle.title3,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: CustomTextStyle.body1,
            children: [
              const TextSpan(text: CustomString.cfqCapital),
              const TextSpan(text: CustomString.space),
              TextSpan(text: when, style: CustomTextStyle.pinkAccentMiniBody),
              const TextSpan(text: CustomString.space),
              const TextSpan(text: CustomString.interrogationMark),
            ],
          ),
        ),
      ],
    );
  }
}
