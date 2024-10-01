import 'package:cloud_firestore/cloud_firestore.dart';

// Model representing a user in the application
class User {
  final String username; // Username of the user
  final String uid; // Unique user ID
  final String bio; // User bio or description
  final String email; // User email address
  final List followers; // List of followers
  final List following; // List of followed users
  final String profilePictureUrl; // URL for the user's profile picture
  final String location; // User's location
  final DateTime? birthDate; // Optional birthdate of the user
  bool isActive; // User's active status

  // Constructor for initializing a User object
  User({
    required this.username,
    required this.uid,
    required this.bio,
    required this.email,
    required this.followers,
    required this.following,
    required this.profilePictureUrl,
    required this.location,
    required this.birthDate,
    required this.isActive,
  });

  // Convert User object to a JSON format for storage
  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "bio": bio,
        "email": email,
        "followers": followers,
        "following": following,
        "profilePictureUrl": profilePictureUrl,
        "location": location,
        "birthDate": birthDate
            ?.toIso8601String(), // Convert birthDate to string if it's not null
        "isActive": isActive,
      };

  // Create a User object from a Firestore snapshot
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      bio: snapshot['bio'],
      email: snapshot['email'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      location: snapshot['location'],
      birthDate: snapshot['birthDate'] != null
          ? DateTime.parse(snapshot['birthDate'])
          : null, // Parse birthDate if it's not null
      isActive: snapshot['isActive'],
    );
  }
}
