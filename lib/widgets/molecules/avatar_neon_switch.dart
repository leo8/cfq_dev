import 'package:flutter/material.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/switches/neon_switch.dart';
import '../../../utils/styles/colors.dart';

class AvatarNeonSwitch extends StatelessWidget {
  final String imageUrl;
  final double avatarRadius;
  final double switchSize;
  final bool isActive;
  final Function(bool)? onChanged;

  const AvatarNeonSwitch({
    super.key,
    required this.imageUrl,
    this.onChanged,
    this.avatarRadius = 40,
    this.switchSize = 1,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? CustomColor.turnColor : CustomColor.offColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? CustomColor.turnColor.withOpacity(0.5)
                    : CustomColor.offColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomAvatar(
            imageUrl: imageUrl,
            radius: avatarRadius,
          ),
        ),
        Positioned(
          bottom: -avatarRadius * 0.2,
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
