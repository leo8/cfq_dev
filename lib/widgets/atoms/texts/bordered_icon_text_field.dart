import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';

class BorderedIconTextField extends StatelessWidget {
  final CustomIcon icon;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final int maxLines;
  final double height;
  final VoidCallback? onTap;

  const BorderedIconTextField({
    super.key,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.maxLines = 1,
    this.height = 46.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: CustomColor.customBlack,
        border: Border.all(color: CustomColor.white, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            alignment: Alignment.center,
            child: icon,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                border: InputBorder.none,
              ),
              style: CustomTextStyle.body1,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
