import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const CustomIconButton({
    required this.icon,
    required this.onTap,
    this.size = 24.0,
    this.color = CustomColor.primaryColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onTap,
    );
  }
}
