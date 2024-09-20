class Turn {
  final String turnName;                // Name of the TURN event
  final String description;             // Description of the event
  final List<String> moods;             // moods associated with the TURN
  final String uid;                     // User ID of the creator
  final String username;                // Username of the creator
  final String turnId;                  // Unique ID for the TURN event
  final DateTime datePublished;         // Date when the TURN was published
  final DateTime eventDateTime;         // Date and time when the event occurs
  final String turnImageUrl;            // URL for the TURN event image
  final String profilePictureUrl;       // Profile picture URL of the creator
  final String where;                   // General location (e.g., "at home", "at a park")
  final String address;                 // Precise address of the event
  final List<String> organizers;        // List of co-organizers
  final List<String> invitees;          // List of invited people
  final List<String> attending;         // List of people attending
  final List<String> notSureAttending;  // List of people who might attend
  final List<String> notAttending;      // List of people who declined
  final List<String> notAnswered;       // List of people who haven't responded
  final List<String> comments;          // List of comments

  Turn({
    required this.turnName,
    required this.description,
    required this.moods,
    required this.uid,
    required this.username,
    required this.turnId,
    required this.datePublished,
    required this.eventDateTime,
    required this.turnImageUrl,
    required this.profilePictureUrl,
    required this.where,
    required this.address,
    required this.organizers,
    required this.invitees,
    required this.attending,
    required this.notSureAttending,
    required this.notAttending,
    required this.notAnswered,
    required this.comments, // Added comments to constructor
  });

  // Convert Turn object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'turnName': turnName,
      'description': description,
      'moods': moods,
      'uid': uid,
      'username': username,
      'turnId': turnId,
      'datePublished': datePublished.toIso8601String(),
      'eventDateTime': eventDateTime.toIso8601String(),
      'turnImageUrl': turnImageUrl,
      'profilePictureUrl': profilePictureUrl,
      'where': where,
      'address': address,
      'organizers': organizers,
      'invitees': invitees,
      'attending': attending,
      'notSureAttending': notSureAttending,
      'notAttending': notAttending,
      'notAnswered': notAnswered,
      'comments': comments, // Included comments in toJson
    };
  }

  // Convert JSON to Turn object
  static Turn fromJson(Map<String, dynamic> json) {
    return Turn(
      turnName: json['turnName'],
      description: json['description'],
      moods: json['moods'],
      uid: json['uid'],
      username: json['username'],
      turnId: json['turnId'],
      datePublished: DateTime.parse(json['datePublished']),
      eventDateTime: DateTime.parse(json['eventDateTime']),
      turnImageUrl: json['turnImageUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      where: json['where'],
      address: json['address'],
      organizers: List<String>.from(json['organizers']),
      invitees: List<String>.from(json['invitees']),
      attending: List<String>.from(json['attending']),
      notSureAttending: List<String>.from(json['notSureAttending']),
      notAttending: List<String>.from(json['notAttending']),
      notAnswered: List<String>.from(json['notAnswered']),
      comments: List<String>.from(json['comments'] ?? []), // Included comments in fromJson
    );
  }
}
