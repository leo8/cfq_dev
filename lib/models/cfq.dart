import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Cfq {
  final String cfqName;
  final String description;
  final String mood;
  final String uid;
  final String username;
  final String cfqId;
  final datePublished;
  final String cfqImageUrl;
  final String profilePictureUrl;
  final List organizers;
  final List followers;

  const Cfq({
    required this.cfqName,
    required this.description,
    required this.mood,
    required this.uid,
    required this.username,
    required this.cfqId,
    required this.datePublished,
    required this.cfqImageUrl,
    required this.profilePictureUrl,
    required this.organizers,
    required this.followers,
  });

  Map<String, dynamic> toJson() => {
        "cfqName": cfqName,
        "description": description,
        "mood": mood,
        "uid": uid,
        "username": username,
        "cfqId": cfqId,
        "datePublished": datePublished,
        "cfqImageUrl": cfqImageUrl,
        "profilePictureUrl": profilePictureUrl,
        "organizers": organizers,
        "followers": followers,
      };

  static Cfq fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Cfq(
      cfqName: snapshot['cfqName'],
      description: snapshot['description'],
      mood: snapshot['mood'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      cfqId: snapshot['cfqId'],
      datePublished: snapshot['datePublished'],
      cfqImageUrl: snapshot['cfqImageUrl'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      organizers: snapshot['organizers'],
      followers: snapshot['followers'],
    );
  }
}
