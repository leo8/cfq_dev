import 'package:flutter/material.dart';
import 'custom_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/styles/colors.dart';

class ClickableAvatar extends StatelessWidget {
  final String userId;
  final String imageUrl;
  final double radius;
  final VoidCallback onTap;
  final bool isActive;

  const ClickableAvatar({
    super.key,
    required this.userId,
    required this.imageUrl,
    required this.onTap,
    this.radius = 30,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = userId == currentUserId;

    return GestureDetector(
      onTap: isCurrentUser ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: CustomColor.turnColor,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: CustomAvatar(
          imageUrl: imageUrl,
          radius: radius,
          borderColor: isActive ? CustomColor.turnColor : null,
          borderWidth: isActive ? 1 : 0,
        ),
      ),
    );
  }
}
