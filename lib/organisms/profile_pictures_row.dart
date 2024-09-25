import 'package:flutter/material.dart';
import 'package:cfq_dev/molecules/profile_avatar.dart';

class ProfilePicturesRow extends StatelessWidget {
  final List<Map<String, String>> profiles; // List of {imageUrl, username}

  const ProfilePicturesRow({
    required this.profiles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(left: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ProfileAvatar(
              imageUrl: profile['imageUrl'] ?? '',
              username: profile['username'] ?? '',
            ),
          );
        },
      ),
    );
  }
}
