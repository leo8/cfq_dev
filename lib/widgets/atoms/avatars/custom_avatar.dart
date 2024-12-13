import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: CustomCachedImageProvider.withCacheManager(
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}
