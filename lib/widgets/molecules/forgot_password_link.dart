import 'package:flutter/material.dart';
import '../../gen/colors.dart';
import '../../gen/fonts.dart';
import '../../gen/string.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        child: const Text(
          CustomString.tAsOublieTonMotDePasse,
          style: TextStyle(color: CustomColor.white70, fontSize: CustomFont.fontSize12),
        ),
      ),
    );
  }
}
