import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';

class SignUpOption extends StatelessWidget {
  final String
      questionText; // The question text, e.g., "Already have an account?"
  final String actionText; // The action text, e.g., "Sign Up"
  final VoidCallback
      onTap; // Callback function triggered when the action text is tapped

  const SignUpOption({
    required this.questionText,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the question and action text
      children: [
        // Display the question text in a subtle color
        Text(
          questionText,
          style: CustomTextStyle.miniBody,
        ),
        // Display the action text, which is clickable and styled in a bold, accent color
        GestureDetector(
          onTap: onTap, // Calls the provided onTap function when tapped
          child: Text(actionText,
              style: CustomTextStyle.personnalizedPurpleTitle1),
        ),
      ],
    );
  }
}
