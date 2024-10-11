import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

class CustomText extends StatelessWidget {
  final String text; // The text to display
  final double? fontSize; // Optional font size for the text
  final FontWeight? fontWeight; // Optional font weight for the text
  final Color? color; // Optional color for the text
  final TextAlign? textAlign; // Optional alignment for the text
  final TextStyle? textStyle; // New parameter for custom text style

  const CustomText({
    required this.text, // Requires a string text to be displayed
    this.fontSize, // Allows setting a custom font size
    this.fontWeight, // Allows setting a custom font weight
    this.color, // Allows setting a custom text colosr
    this.textAlign, // Allows setting the text alignment
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text, // The actual text displayed in the widget
      textAlign: textAlign, // Aligns text if specified
      style: textStyle ??
          TextStyle(
            fontSize: fontSize ?? 16, // Default font size if not provided
            fontWeight: fontWeight ??
                FontWeight.normal, // Default font weight if not provided
            color: color ?? CustomColor.white, // Default color if not provided
          ),
    );
  }
}
