import 'package:flutter/material.dart';

import '../../../gen/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines; // Added maxLines parameter

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1, // Default value is 1 for single-line input
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines, // Use the maxLines parameter here
        style: const TextStyle(color: CustomColor.primaryColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: CustomColor.white70),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
