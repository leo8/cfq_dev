import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onTap,
    );
  }
}
