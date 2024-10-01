import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final OutlinedBorder? shape;

  const CustomElevatedButton({
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.shape,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: backgroundColor != null
            ? WidgetStateProperty.all<Color>(backgroundColor!)
            : null,
        shape: shape != null
            ? WidgetStateProperty.all<OutlinedBorder>(shape!)
            : null,
      ),
      child: child,
    );
  }
}
