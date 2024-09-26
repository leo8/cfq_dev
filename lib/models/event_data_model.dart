
class EventDataModel {
  final String name;
  final String description;
  final List<String> moods;
  final String uid;                     // User ID of the creator
  final String username;                // Username of the creator
  final String eventId;                  // Unique ID for the TURN event
  final DateTime datePublished;         // Date when the CFQ was published
  final String imageUrl;             // URL for the CFQ image
  final String where;                   // General location (e.g., "at home", "at a park")
  final List<String> organizers;        // List of co-organizers
  final String profilePictureUrl;       // Profile picture URL of the creator
  final List<String> comments;

  EventDataModel({
    required this.name,
    required this.description,
    required this.moods,
    required this.uid,
    required this.username,
    required this.eventId,
    required this.datePublished,
    required this.imageUrl,
    required this.profilePictureUrl,
    required this.where,
    required this.organizers,
    required this.comments, // Added comments to constructor
  });
}