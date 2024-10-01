import 'package:flutter/material.dart';

import '../molecules/profile_avatar.dart';

class ProfilePicturesRow extends StatelessWidget {
  final List<Map<String, String>>
      profiles; // List of profile data containing image URLs and usernames

  const ProfilePicturesRow({
    required this.profiles, // Require a list of profiles
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Fixed height for the profile pictures row
      padding:
          const EdgeInsets.only(left: 10), // Left padding for the container
      child: ListView.builder(
        scrollDirection:
            Axis.horizontal, // Horizontal scrolling for profile pictures
        itemCount: profiles.length, // Number of profiles to display
        itemBuilder: (context, index) {
          final profile =
              profiles[index]; // Get profile data for the current index
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12.0), // Padding around each profile
            child: ProfileAvatar(
              imageUrl: profile['imageUrl'] ?? '', // Profile image URL
              username: profile['username'] ?? '', // Profile username
            ),
          );
        },
      ),
    );
  }
}
