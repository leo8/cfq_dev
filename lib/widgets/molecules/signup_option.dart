import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class SignUpOption extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onTap;

  const SignUpOption({
    required this.questionText,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: const TextStyle(color: CustomColor.white70),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: CustomColor.personnalizedPurple,
              fontWeight: CustomFont.fontWeightBold,
            ),
          ),
        ),
      ],
    );
  }
}
