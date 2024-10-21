import 'package:cloud_firestore/cloud_firestore.dart';

// Model representing a user in the application
class User {
  final String username; // Username of the user
  final String uid; // Unique user ID
  final String email; // User email address
  final List friends; // List of friends 'uid
  final List teams; // List of teams 'uid
  final String profilePictureUrl; // URL for the user's profile picture
  final String location; // User's location
  final DateTime? birthDate; // Optional birthdate of the user
  bool isActive; // User's active status
  final String searchKey; // Used to facilitate user search
  final List postedTurns; // List of turns 'uid
  final List invitedTurns; // List of turns 'uid
  final List postedCfqs; // List of cfqs 'uid
  final List invitedCfqs; // List of cfqs 'uid
  final List favorites; // List of favorite items
  final List conversations; // List of favorite items

  // Constructor for initializing a User object
  User({
    required this.username,
    required this.uid,
    required this.email,
    required this.friends,
    required this.teams,
    required this.profilePictureUrl,
    required this.location,
    required this.birthDate,
    required this.isActive,
    required this.searchKey,
    required this.postedTurns,
    required this.invitedTurns,
    required this.postedCfqs,
    required this.invitedCfqs,
    required this.favorites,
    required this.conversations,
  });

  // Convert User object to a JSON format for storage
  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "friends": friends,
        "teams": teams,
        "profilePictureUrl": profilePictureUrl,
        "location": location,
        "birthDate": birthDate
            ?.toIso8601String(), // Convert birthDate to string if it's not null
        "isActive": isActive,
        "searchKey": searchKey,
        "postedTurns": postedTurns,
        "invitedTurns": invitedTurns,
        "postedCfqs": postedCfqs,
        "invitedCfqs": invitedCfqs,
        "favorites": favorites,
        "conversations:": conversations,
      };

  // Create a User object from a Firestore snapshot
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
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
      postedTurns: snapshot['postedTurns'],
      invitedTurns: snapshot['invitedTurns'],
      postedCfqs: snapshot['postedCfqs'],
      invitedCfqs: snapshot['invitedCfqs'],
      favorites: snapshot['favorites'],
      conversations: snapshot['conversations'],
    );
  }
}
