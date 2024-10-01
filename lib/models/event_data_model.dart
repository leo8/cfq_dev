// Base model for representing event data (used by both CFQ and TURN)
class EventDataModel {
  final String name; // Name of the event
  final String description; // Description of the event
  final List<String> moods; // List of moods or tags related to the event
  final String uid; // User ID of the creator
  final String username; // Username of the creator
  final String eventId; // Unique identifier for the event
  final DateTime datePublished; // Date when the event was published
  final String imageUrl; // URL for the event's image
  final String where; // General location (e.g., "at home", "at a park")
  final List<String> organizers; // List of co-organizers for the event
  final String profilePictureUrl; // Profile picture URL of the creator
  final List<String> comments; // List of comments related to the event

  // Constructor to initialize the event data model
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
    required this.comments, // Includes comments in the constructor
  });
}
