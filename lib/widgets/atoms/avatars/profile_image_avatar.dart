import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';

class ProfileImageAvatar extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onImageSelected;
  final bool isLoading;

  const ProfileImageAvatar({
    super.key,
    this.image,
    required this.onImageSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 64,
          backgroundColor: CustomColor.customBlack,
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(CustomColor.white70),
                )
              : CircleAvatar(
                  radius: 62,
                  backgroundImage: image != null
                      ? MemoryImage(image!)
                      : const NetworkImage(
                          'https://as1.ftcdn.net/v2/jpg/05/16/27/58/1000_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg',
                        ) as ImageProvider,
                ),
        ),
        Positioned(
          bottom: -10,
          left: 80,
          child: IconButton(
            onPressed: onImageSelected,
            icon: CustomIcon.addImage,
          ),
        ),
      ],
    );
  }
}
