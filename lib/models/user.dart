import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class User {
  final String username;
  final String uid;
  final String bio;
  final String email;
  final List followers;
  final List following;
  final String profilePictureUrl;

  const User({
    required this.username,
    required this.uid,
    required this.bio,
    required this.email,
    required this.followers,
    required this.following,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "bio": bio,
        "email": email,
        "followers": followers,
        "following": following,
        "profilePictureUrl": profilePictureUrl,
      };
  
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
    );
  }
}