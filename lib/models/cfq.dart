class Cfq {
  final String cfqName;                 // Name of the CFQ (discussion/topic)
  final String description;             // Description of the CFQ
  final String mood;                    // Mood associated with the CFQ
  final String uid;                     // User ID of the creator
  final String username;                // Username of the creator
  final String cfqId;                   // Unique ID for the CFQ
  final DateTime datePublished;         // Date when the CFQ was published
  final String cfqImageUrl;             // URL for the CFQ image
  final String profilePictureUrl;       // Profile picture URL of the creator
  final String where;                   // General location (e.g., "online", "at home")
  final List<String> organizers;        // List of co-organizers or main contributors
  final List<String> followers;         // List of followers of the CFQ
  final List<String> comments;          // List of comments

  Cfq({
    required this.cfqName,
    required this.description,
    required this.mood,
    required this.uid,
    required this.username,
    required this.cfqId,
    required this.datePublished,
    required this.cfqImageUrl,
    required this.profilePictureUrl,
    required this.where,
    required this.organizers,
    required this.followers,
    required this.comments, // Added comments to constructor
  });

  // Convert Cfq object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'cfqName': cfqName,
      'description': description,
      'mood': mood,
      'uid': uid,
      'username': username,
      'cfqId': cfqId,
      'datePublished': datePublished.toIso8601String(),
      'cfqImageUrl': cfqImageUrl,
      'profilePictureUrl': profilePictureUrl,
      'where': where,
      'organizers': organizers,
      'followers': followers,
      'comments': comments, // Included comments in toJson
    };
  }

  // Convert JSON to Cfq object
  static Cfq fromJson(Map<String, dynamic> json) {
    return Cfq(
      cfqName: json['cfqName'],
      description: json['description'],
      mood: json['mood'],
      uid: json['uid'],
      username: json['username'],
      cfqId: json['cfqId'],
      datePublished: DateTime.parse(json['datePublished']),
      cfqImageUrl: json['cfqImageUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      where: json['where'],
      organizers: List<String>.from(json['organizers']),
      followers: List<String>.from(json['followers']),
      comments: List<String>.from(json['comments'] ?? []), // Included comments in fromJson
    );
  }
}
