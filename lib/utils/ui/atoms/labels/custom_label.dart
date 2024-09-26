import 'package:flutter/material.dart';

import '../../../gen/colors.dart';
import '../../../gen/fonts.dart';

class CustomLabel extends StatelessWidget {
  final String text;

  const CustomLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CustomColor.primaryColor,
        fontWeight: CustomFont.fontWeightBold,
        fontSize: CustomFont.fontSize14,
      ),
    );
  }
}
