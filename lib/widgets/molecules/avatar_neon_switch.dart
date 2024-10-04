import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/switches/neon_switch.dart';
import 'package:flutter/material.dart';

class AvatarNeonSwitch extends StatelessWidget {
  final String imageUrl; // Avatar image URL
  final double avatarRadius; // Avatar radius
  final double switchSize; // NeonSwitch size factor
  final bool isActive; // Current value for the NeonSwitch (active status)
  final Function(bool)?
      onChanged; // Callback to handle switch value changes, nullable

  const AvatarNeonSwitch({
    required this.imageUrl,
    this.onChanged, // Nullable onChanged
    this.avatarRadius = 75, // Default radius for the avatar
    this.switchSize = 0.65, // Default size for the NeonSwitch
    this.isActive = false, // Default active status is OFF
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Allows overlap of the NeonSwitch
      children: [
        // Custom Avatar
        CustomAvatar(
          imageUrl: imageUrl,
          radius: avatarRadius, // Avatar size
        ),
        // Positioned NeonSwitch at the bottom
        Positioned(
          bottom: -avatarRadius * 0.35, // Adjust this to overlap the switch
          child: NeonSwitch(
            size: switchSize, // NeonSwitch size
            value: isActive, // Pass active status to NeonSwitch
            onChanged: onChanged, // Handle switch value changes
          ),
        ),
      ],
    );
  }
}
