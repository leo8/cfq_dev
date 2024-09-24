import 'package:cfq_dev/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
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
