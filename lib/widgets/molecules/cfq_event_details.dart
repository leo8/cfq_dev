import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

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
          color: CustomColor.white,
          fontSize: CustomFont.fontSize20,
          fontWeight: CustomFont.fontWeightBold,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: CustomColor.white,
              fontSize: CustomFont.fontSize16,
            ),
            children: [
              const TextSpan(text: 'CFQ '),
              TextSpan(
                text: when,
                style: const TextStyle(color: CustomColor.pinkAccent),
              ),
              const TextSpan(text: ' ?'),
            ],
          ),
        ),
      ],
    );
  }
}
