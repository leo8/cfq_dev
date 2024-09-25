import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final double radius;
  final ImageProvider? backgroundImage;

  const CustomCircleAvatar({
    required this.radius,
    this.backgroundImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: backgroundImage,
    );
  }
}
