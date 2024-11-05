import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';

class OutlinedIconButton extends StatelessWidget {
  final CustomIcon icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color color;

  const OutlinedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 60.0,
    this.iconSize = 30.0,
    this.color = CustomColor.customWhite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(color: color),
          padding: EdgeInsets.zero, // Remove default padding
        ),
        onPressed: onPressed,
        child: icon.copyWith(
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
