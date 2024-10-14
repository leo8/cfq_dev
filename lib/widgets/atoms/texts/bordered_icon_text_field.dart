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
    this.height = 40.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.white, width: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: icon,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: CustomTextStyle.miniBody,
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
