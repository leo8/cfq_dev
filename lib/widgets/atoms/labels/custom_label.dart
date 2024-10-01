import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/fonts.dart';

class CustomLabel extends StatelessWidget {
  final String text;

  const CustomLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CustomColor.white,
        fontWeight: CustomFont.fontWeightBold,
        fontSize: CustomFont.fontSize14,
      ),
    );
  }
}
