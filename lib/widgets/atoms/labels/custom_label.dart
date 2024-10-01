import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/fonts.dart';

class CustomLabel extends StatelessWidget {
  final String text; // Text to display

  const CustomLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text, // The text to be displayed in the label
      style: const TextStyle(
        color: CustomColor.white, // Sets the text color to white
        fontWeight: CustomFont.fontWeightBold, // Uses a bold font weight
        fontSize: CustomFont.fontSize14, // Sets the font size to 14
      ),
    );
  }
}
