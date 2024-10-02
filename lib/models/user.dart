import 'package:cloud_firestore/cloud_firestore.dart';

// Model representing a user in the application
class User {
  final String username; // Username of the user
  final String uid; // Unique user ID
  final String bio; // User bio or description
  final String email; // User email address
  final List<String> friends; // List of friends 'uid
  final List<String> teams; // List of teams 'uid
  final String profilePictureUrl; // URL for the user's profile picture
  final String location; // User's location
  final DateTime? birthDate; // Optional birthdate of the user
  bool isActive; // User's active status
  final String searchKey; // Used to facilitate user search

  // Constructor for initializing a User object
  User(
      {required this.username,
      required this.uid,
      required this.bio,
      required this.email,
      required this.friends,
      required this.teams,
      required this.profilePictureUrl,
      required this.location,
      required this.birthDate,
      required this.isActive,
      required this.searchKey});

  // Convert User object to a JSON format for storage
  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "bio": bio,
        "email": email,
        "friends": friends,
        "teams": teams,
        "profilePictureUrl": profilePictureUrl,
        "location": location,
        "birthDate": birthDate
            ?.toIso8601String(), // Convert birthDate to string if it's not null
        "isActive": isActive,
        "searchKey": searchKey,
      };

  // Create a User object from a Firestore snapshot
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      bio: snapshot['bio'],
      email: snapshot['email'],
      friends: snapshot['friends'],
      teams: snapshot['teams'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      location: snapshot['location'],
      birthDate: snapshot['birthDate'] != null
          ? DateTime.parse(snapshot['birthDate'])
          : null, // Parse birthDate if it's not null
      isActive: snapshot['isActive'],
      searchKey: snapshot['searchKey'],
    );
  }
}
