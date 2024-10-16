import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Color borderColor; // Added optional border color
  final double? borderWidth; // Added border width with default value

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.textStyle,
    this.borderColor = CustomColor.customWhite,
    this.borderWidth, // Default border width
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: CustomColor.customWhite,
              ),
            )
          : Container(
              width: width ?? double.infinity,
              height: height,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius ?? 7),
                color: color ?? CustomColor.customWhite,
                border: borderWidth != null
                    ? Border.all(
                        color: borderColor,
                        width: borderWidth!,
                      )
                    : null,
              ),
              child: Text(
                label,
                style: textStyle ??
                    CustomTextStyle.subButton.copyWith(
                      color: CustomColor.customBlack,
                    ),
              ),
            ),
    );
  }
}
