import 'package:flutter/material.dart';

class CFQCard extends StatelessWidget {
  final String profilePictureUrl; // Profile picture URL of the creator
  final String username; // Username of the creator
  final List<String> organizers; // Co-organizers or contributors (List of Strings)
  final String cfqName; // Name of the CFQ (discussion/topic)
  final String description; // Description of the CFQ
  final DateTime datePublished; // Date when the CFQ was published
  final String where; // General location (e.g., "online", "at home")
  final List<String> followers; // Followers of the CFQ (List of Strings)

  const CFQCard({
    Key? key,
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.cfqName,
    required this.description,
    required this.datePublished,
    required this.where,
    required this.followers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0551), // Similar purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24), // Border for slight effect
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(profilePictureUrl),
              ),
              const SizedBox(width: 12),
              // Username and Additional Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Display organizers list joined by commas
                        Text(
                          'à ${organizers.join(', ')}',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${datePublished.day}/${datePublished.month}/${datePublished.year}', // Dynamic date
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              // Attendee Button (Followers count can be displayed here)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A00FF), // Gradient-like effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Follow'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Event Details
          Row(
            children: [
              const Icon(Icons.event, color: Colors.white54, size: 20), // CFQ Icon
              const SizedBox(width: 4),
              Text(
                'CFQ',
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // CFQ Name (Topic Title)
          Text(
            cfqName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Event Description
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          // Location (Where it's happening)
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 20),
              const SizedBox(width: 4),
              Text(
                where,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons (Share, Send, Comment)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
