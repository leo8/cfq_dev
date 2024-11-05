import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String uid;
  final String name;
  final String imageUrl;
  final List members;
  final List invitedCfqs;
  final List invitedTurns;

  Team({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.members,
    required this.invitedCfqs,
    required this.invitedTurns,
  });

  // Convert Team object to JSON format for Firestore
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "imageUrl": imageUrl,
        "members": members,
        "invitedCfqs": invitedCfqs,
        "invitedTurns": invitedTurns,
      };

  // Create a Team object from a Firestore snapshot
  static Team fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Team(
      uid: snapshot['uid'],
      name: snapshot['name'],
      imageUrl: snapshot['imageUrl'],
      members: snapshot['members'],
      invitedCfqs: snapshot['invitedCfqs'],
      invitedTurns: snapshot['invitedTurns'],
    );
  }
}
