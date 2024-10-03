import 'package:flutter/material.dart';
import '../atoms/texts/custom_text_field.dart';
import '../../utils/styles/colors.dart';

/// A molecule that combines an icon with a custom text field.
/// Displays an icon inside the text field container on the left side.
class CustomIconTextField extends StatelessWidget {
  final IconData icon; // Icon to display inside the text field
  final TextEditingController controller; // Controller for the text field
  final String hintText; // Hint text for the text field
  final bool obscureText; // Whether to obscure the text (e.g., for passwords)
  final Widget? suffixIcon; // Optional suffix icon
  final int maxLines; // Maximum number of lines
  final ValueChanged<String>? onChanged; // Optional onChanged callback
  final double? height; // Optional height parameter

  const CustomIconTextField({
    required this.icon,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      suffixIcon: suffixIcon,
      maxLines: maxLines,
      onChanged: onChanged,
      height: height,
      icon: Icon(
        icon,
        color: CustomColor.white,
        size: 24.0, // Consistent icon size
      ), // Pass the icon as a separate widget
    );
  }
}
