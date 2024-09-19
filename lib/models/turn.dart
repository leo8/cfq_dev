import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Turn {
  final String turnName;
  final String description;
  final String mood;
  final String uid;
  final String username;
  final String turnId;
  final datePublished;
  final String turnImageUrl;
  final String profilePictureUrl;
  final List organizers;
  final List attending;
  final List notSureAttending;
  final List notAttending;
  final List notAnswered;

  const Turn({
    required this.turnName,
    required this.description,
    required this.mood,
    required this.uid,
    required this.username,
    required this.turnId,
    required this.datePublished,
    required this.turnImageUrl,
    required this.profilePictureUrl,
    required this.organizers,
    required this.attending,
    required this.notSureAttending,
    required this.notAttending,
    required this.notAnswered,
  });

  Map<String, dynamic> toJson() => {
        "turnName": turnName,
        "description": description,
        "mood": mood,
        "uid": uid,
        "username": username,
        "turnId": turnId,
        "datePublished": datePublished,
        "turnImageUrl": turnImageUrl,
        "profilePictureUrl": profilePictureUrl,
        "organizers": organizers,
        "attending": attending,
        "notSureAttending": notSureAttending,
        "notAttending": notAttending,
        "notAnswered": notAnswered,
      };

  static Turn fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Turn(
      turnName: snapshot['turnName'],
      description: snapshot['description'],
      mood: snapshot['mood'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      turnId: snapshot['turnId'],
      datePublished: snapshot['datePublished'],
      turnImageUrl: snapshot['turnImageUrl'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      organizers: snapshot['organizers'],
      attending: snapshot['attending'],
      notSureAttending: snapshot['notSureAttending'],
      notAttending: snapshot['notAttending'],
      notAnswered: snapshot['notAnswered'],
    );
  }
}
