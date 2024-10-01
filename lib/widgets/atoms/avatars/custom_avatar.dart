import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  // Constructor to accept the avatar image URL and radius (with a default value).
  const CustomAvatar({
    required this.imageUrl, // URL for the avatar image
    this.radius = 30, // Default radius is set to 30, can be customized
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius, // Set the radius of the avatar
      backgroundImage:
          NetworkImage(imageUrl), // Fetch the image from the provided URL
    );
  }
}
