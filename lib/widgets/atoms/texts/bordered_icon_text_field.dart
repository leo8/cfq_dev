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
  final BorderRadius? borderRadius;
  final TextStyle? hintTextStyle;
  final Function(String)? onChanged;
  final int? maxLength;
  final bool clearOption;
  final VoidCallback? onClear;

  const BorderedIconTextField({
    super.key,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.maxLines = 1,
    this.height = 46.0,
    this.onTap,
    this.borderRadius,
    this.hintTextStyle,
    this.onChanged,
    this.maxLength,
    this.clearOption = false,
    this.onClear,
  });

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
            width: 48,
            alignment: Alignment.center,
            child: icon,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintTextStyle ??
                    CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                border: InputBorder.none,
                counterText: '',
              ),
              maxLength: maxLength,
              style: CustomTextStyle.body1,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
            ),
          ),
          if (clearOption && controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: CustomColor.grey800,
                  shape: BoxShape.circle,
                ),
                child: CustomIcon.close.copyWith(
                  size: 12,
                  color: CustomColor.customWhite,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
