import 'package:flutter/material.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/switches/neon_switch.dart';

class AvatarNeonSwitch extends StatelessWidget {
  final String imageUrl;
  final double avatarRadius;
  final double switchSize;
  final bool isActive;
  final Function(bool)? onChanged;

  const AvatarNeonSwitch({
    Key? key,
    required this.imageUrl,
    this.onChanged,
    this.avatarRadius = 40,
    this.switchSize = 1,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        CustomAvatar(
          imageUrl: imageUrl,
          radius: avatarRadius,
        ),
        Positioned(
          bottom: -avatarRadius * 0.25,
          child: NeonSwitch(
            size: switchSize,
            value: isActive,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
