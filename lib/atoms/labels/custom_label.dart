import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';

class CustomLabel extends StatelessWidget {
  final String text;

  const CustomLabel({required this.text, Key? key}) : super(key: key);

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
