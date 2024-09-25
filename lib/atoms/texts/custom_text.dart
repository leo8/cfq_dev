import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const CustomText({
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? CustomFont.fontSize16,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? CustomColor.primaryColor,
      ),
    );
  }
}
