import 'package:flutter/material.dart';

class CFQCard extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String additionalUsers;
  final String eventTitle;
  final String eventType;
  final String date;
  final String time;
  final String description;
  final String location;
  final String exactLocation;
  final int attendees;
  final int comments;

  const CFQCard({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.additionalUsers,
    required this.eventTitle,
    required this.eventType,
    required this.date,
    required this.time,
    required this.description,
    required this.location,
    required this.exactLocation,
    required this.attendees,
    required this.comments,
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
                backgroundImage: NetworkImage(profileImageUrl),
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
                        Text(
                          'à $additionalUsers',
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
                      '3h', // Static for now, replace with dynamic time later
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              // Attendee Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A00FF), // Gradient-like effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('T’y vas?'),
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
                eventType,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Event Title
          Text(
            eventTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Event Date and Time
          Text(
            '$date | $time',
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.w500,
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
          // Location and Exact Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 20),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 4),
              Text(
                exactLocation,
                style: const TextStyle(color: Colors.white54),
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
