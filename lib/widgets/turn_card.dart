import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:flutter/material.dart';

class TurnCard extends StatelessWidget {
  final String profilePictureUrl; // Profile picture URL of the creator
  final String username; // Username of the creator
  final List<String> organizers; // Co-organizers (List of Strings)
  final String turnName; // Name of the TURN event
  final String description; // Description of the event
  final DateTime eventDateTime; // Date and time when the event occurs
  final String where; // General location (e.g., "at home")
  final String address; // Precise address
  final List<String> attending; // List of attendees
  final List<String> comments; // Comments are usually a list

  const TurnCard({
    Key? key,
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.turnName,
    required this.description,
    required this.eventDateTime,
    required this.where,
    required this.address,
    required this.attending,
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
        border: Border.all(color: CustomColor.white24), // Border for slight effect
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
                            color: CustomColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Display organizers list joined by commas
                        Text(
                          'à ${organizers.join(', ')}',
                          style: const TextStyle(
                            color: CustomColor.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CustomString.uneHeure, // Placeholder, dynamic time can be calculated
                      style: const TextStyle(color: CustomColor.white54),
                    ),
                  ],
                ),
              ),
              // Attendee Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.personnalizedPurple, // Gradient-like effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(CustomString.jeSuisLa),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Event Details
          Row(
            children: [
              const Icon(Icons.home, color: CustomColor.white54, size: 20), // Appart Icon
              const SizedBox(width: 4),
              Text(
                where, // Use the 'where' field for location type
                style: const TextStyle(color: CustomColor.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Event Title (Turn Name)
          Text(
            turnName,
            style: const TextStyle(
              color: CustomColor.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Event Date and Time
          Text(
            '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year} | ${eventDateTime.hour}:${eventDateTime.minute}',
            style: const TextStyle(
              color: CustomColor.pinkAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Event Description
          Text(
            description,
            style: const TextStyle(
              color: CustomColor.white70,
            ),
          ),
          const SizedBox(height: 16),
          // Location and Exact Location
          Row(
            children: [
              const Icon(Icons.location_on, color: CustomColor.white54, size: 20),
              const SizedBox(width: 4),
              Text(
                where, // General location (e.g., "at home")
                style: const TextStyle(color: CustomColor.white70),
              ),
              const SizedBox(width: 4),
              Text(
                address, // Precise address
                style: const TextStyle(color: CustomColor.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons (Share, Send, Comment)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: CustomColor.white54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send, color: CustomColor.white54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: CustomColor.white54),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
