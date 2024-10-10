import 'package:flutter/material.dart';
import 'custom_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClickableAvatar extends StatelessWidget {
  final String userId;
  final String imageUrl;
  final double radius;
  final VoidCallback onTap;
  const ClickableAvatar({
    super.key,
    required this.userId,
    required this.imageUrl,
    required this.onTap,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = userId == currentUserId;

    return GestureDetector(
      onTap: isCurrentUser ? null : onTap,
      child: CustomAvatar(
        imageUrl: imageUrl,
        radius: radius,
      ),
    );
  }
}
