import 'package:cfq_dev/models/event_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Turn model representing a specific event type, extending EventDataModel
class Turn extends EventDataModel {
  final DateTime eventDateTime; // Date and time when the event occurs
  final String address; // Precise address of the event
  final List<String> attending; // List of people confirmed to attend
  final List<String> notSureAttending; // List of people unsure about attending
  final List<String> notAttending; // List of people who declined the invitation
  final List<String> notAnswered; // List of people who haven't responded

  // Constructor initializing Turn-specific fields and inheriting from EventDataModel
  Turn(
      {required this.eventDateTime,
      required this.address,
      required this.attending,
      required this.notSureAttending,
      required this.notAttending,
      required this.notAnswered,
      required super.name,
      required super.description,
      required super.moods,
      required super.uid,
      required super.username,
      required super.eventId,
      required super.datePublished,
      required super.imageUrl,
      required super.profilePictureUrl,
      required super.where,
      required super.organizers,
      required super.teamInvitees,
      required super.invitees,
      required super.channelId});

  // Convert Turn object to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'turnName': name,
      'description': description,
      'moods': moods,
      'uid': uid,
      'username': username,
      'turnId': eventId,
      'datePublished': datePublished.toIso8601String(),
      'eventDateTime': eventDateTime.toIso8601String(),
      'turnImageUrl': imageUrl,
      'profilePictureUrl': profilePictureUrl,
      'where': where,
      'address': address,
      'organizers': organizers,
      'invitees': invitees,
      'teamInvitees': teamInvitees,
      'attending': attending,
      'notSureAttending': notSureAttending,
      'notAttending': notAttending,
      'notAnswered': notAnswered,
      'channelId': channelId,
    };
  }

  // Convert JSON data to Turn object
  static Turn fromJson(Map<String, dynamic> json) {
    return Turn(
      name: json['turnName'],
      description: json['description'],
      moods: List<String>.from(json['moods']),
      uid: json['uid'],
      username: json['username'],
      eventId: json['turnId'],
      datePublished: DateTime.parse(json['datePublished']),
      eventDateTime: DateTime.parse(json['eventDateTime']),
      imageUrl: json['turnImageUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      where: json['where'],
      address: json['address'],
      organizers: List<String>.from(json['organizers']),
      invitees: List<String>.from(json['invitees']),
      teamInvitees: List<String>.from(json['teamInvitees']),
      attending: List<String>.from(json['attending']),
      notSureAttending: List<String>.from(json['notSureAttending']),
      notAttending: List<String>.from(json['notAttending']),
      notAnswered: List<String>.from(json['notAnswered']),
      channelId: json['channelId'],
    );
  }

  factory Turn.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Turn(
      name: snapshot['name'] ?? '',
      description: snapshot['description'] ?? '',
      moods: List<String>.from(snapshot['moods'] ?? []),
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? '',
      eventId: snapshot['eventId'] ?? '',
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
      eventDateTime: (snapshot['eventDateTime'] as Timestamp).toDate(),
      imageUrl: snapshot['imageUrl'] ?? '',
      profilePictureUrl: snapshot['profilePictureUrl'] ?? '',
      where: snapshot['where'] ?? '',
      address: snapshot['address'] ?? '',
      organizers: List<String>.from(snapshot['organizers'] ?? []),
      invitees: List<String>.from(snapshot['invitees'] ?? []),
      teamInvitees: List<String>.from(snapshot['teamInvitees'] ?? []),
      attending: List<String>.from(snapshot['attending'] ?? []),
      notSureAttending: List<String>.from(snapshot['notSureAttending'] ?? []),
      notAttending: List<String>.from(snapshot['notAttending'] ?? []),
      notAnswered: List<String>.from(snapshot['notAnswered'] ?? []),
      channelId: snapshot['channelId'] ?? '',
    );
  }
}
