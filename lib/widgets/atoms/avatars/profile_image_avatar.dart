import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../gen/colors.dart';
import '../../../gen/icons.dart';

class ProfileImageAvatar extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onImageSelected;

  const ProfileImageAvatar({super.key, 
    this.image,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 64,
          backgroundImage: image != null
              ? MemoryImage(image!)
              : const NetworkImage(
                  'https://as1.ftcdn.net/v2/jpg/05/16/27/58/1000_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg',
                ) as ImageProvider,
        ),
        Positioned(
          bottom: -10,
          left: 80,
          child: IconButton(
            onPressed: onImageSelected,
            icon: const Icon(
              CustomIcon.addAPhoto,
              color: CustomColor.white70,
            ),
          ),
        ),
      ],
    );
  }
}
