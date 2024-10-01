import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

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
        child: const Text(
          CustomString.tAsOublieTonMotDePasse, // "Forgot Password" text
          style: TextStyle(
            color: CustomColor.white70, // Semi-transparent white text color
            fontSize: CustomFont.fontSize12, // Small font size
          ),
        ),
      ),
    );
  }
}
