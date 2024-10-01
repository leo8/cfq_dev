import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final double radius;
  final ImageProvider? backgroundImage;

  // Constructor to accept the radius and an optional background image
  const CustomCircleAvatar({
    required this.radius, // The radius for the avatar, which is a required parameter
    this.backgroundImage, // Optional background image, if provided, it will be used
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius, // Sets the radius of the circle avatar
      backgroundImage:
          backgroundImage, // If backgroundImage is provided, it's used as the avatar image
    );
  }
}
