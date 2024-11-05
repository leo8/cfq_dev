import 'package:flutter/material.dart';
import '../../utils/styles/string.dart';
import '../../../utils/styles/text_styles.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap; // Callback when the link is tapped

  const ForgotPasswordLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight, // Aligns the link to the right
      child: TextButton(
        onPressed: onTap, // Triggers the provided onTap callback
        child: Text(CustomString.forgotPassword, // "Forgot Password" text
            style: CustomTextStyle.xsBody),
      ),
    );
  }
}
