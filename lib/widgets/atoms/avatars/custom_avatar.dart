import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  const CustomAvatar({
    Key? key,
    required this.imageUrl,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}
