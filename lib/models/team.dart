// team.dart

import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String uid;
  final String name;
  final String imageUrl;
  final List members;

  Team({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.members,
  });

  // Convert Team object to JSON format for Firestore
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "imageUrl": imageUrl,
        "members": members,
      };

  // Create a Team object from a Firestore snapshot
  static Team fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Team(
      uid: snapshot['uid'],
      name: snapshot['name'],
      imageUrl: snapshot['imageUrl'],
      members: snapshot['members'],
    );
  }
}
