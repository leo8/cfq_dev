import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/text_styles.dart';

class BorderedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final int maxLines;
  final double height;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final TextStyle? hintTextStyle;
  final Function(String)? onChanged;

  const BorderedTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.readOnly = false,
      this.maxLines = 1,
      this.height = 46.0,
      this.onTap,
      this.borderRadius,
      this.hintTextStyle,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: CustomColor.customBlack,
        border: Border.all(color: CustomColor.customWhite, width: 0.5),
        borderRadius: borderRadius ?? BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            alignment: Alignment.center,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintTextStyle ??
                    CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                border: InputBorder.none,
              ),
              style: CustomTextStyle.body1,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
