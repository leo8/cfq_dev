import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

class OutlinedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color color;

  const OutlinedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 60.0,
    this.iconSize = 30.0,
    this.color = CustomColor.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: CircleBorder(),
          side: BorderSide(color: color),
          padding: EdgeInsets.zero, // Remove default padding
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
