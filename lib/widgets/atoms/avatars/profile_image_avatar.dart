import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';

class ProfileImageAvatar extends StatelessWidget {
  final Uint8List? image; // Nullable image data of the profile picture
  final VoidCallback
      onImageSelected; // Callback function triggered when selecting an image

  // Constructor
  const ProfileImageAvatar({
    super.key,
    this.image, // Optional image, can be null
    required this.onImageSelected, // Required callback to select a new image
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Circle avatar with profile image or placeholder
        CircleAvatar(
          radius: 64, // Size of the avatar
          backgroundImage: image != null
              ? MemoryImage(image!) // If an image is provided, use it
              : const NetworkImage(
                  // Default placeholder image if no image is provided
                  'https://as1.ftcdn.net/v2/jpg/05/16/27/58/1000_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg',
                ) as ImageProvider,
        ),
        // Positioned icon to add or update the profile picture
        Positioned(
          bottom: -10,
          left: 80, // Position of the icon relative to the avatar
          child: IconButton(
            onPressed:
                onImageSelected, // Call the provided callback when the icon is pressed
            icon: const Icon(
              CustomIcon.addAPhoto, // Custom icon for adding a photo
              color: CustomColor.white70, // Icon color
            ),
          ),
        ),
      ],
    );
  }
}
