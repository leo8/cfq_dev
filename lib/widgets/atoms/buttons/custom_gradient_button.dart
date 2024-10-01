import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/fonts.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomGradientButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [CustomColor.personnalizedPurple, Color(0xFF7900F4)],
          ),
        ),
        child: CustomText(
          text: text,
          fontSize: CustomFont.fontSize18,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
      ),
    );
  }
}
