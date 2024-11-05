import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';

class CustomIconButton extends StatelessWidget {
  final CustomIcon icon; // The icon displayed inside the button
  final VoidCallback onTap; // The function triggered when the button is pressed
  final double size; // The size of the icon
  final Color color; // The color of the icon

  const CustomIconButton({
    required this.icon, // The icon is required to be passed to the button
    required this.onTap, // The onTap callback function is required
    this.size = 24.0, // Default icon size is set to 24.0
    this.color = CustomColor.customWhite, // Default icon color is white
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon.copyWith(color: color, size: size),
      onPressed: onTap, // Call the provided onTap function when pressed
    );
  }
}
