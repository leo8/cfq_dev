import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final ShapeBorder? shape;

  const CustomElevatedButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.shape,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: shape,
      ),
      child: child,
    );
  }
}
