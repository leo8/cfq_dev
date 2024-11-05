import 'package:cfq_dev/models/event_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Turn model representing a specific event type, extending EventDataModel
class Turn extends EventDataModel {
  final DateTime eventDateTime; // Date and time when the event occurs
  final DateTime? endDateTime; // Add this line
  final List<String> attending; // List of people confirmed to attend
  final List<String> notSureAttending; // List of people unsure about attending
  final List<String> notAttending; // List of people who declined the invitation
  final List<String> notAnswered; // List of people who haven't responded
  final String? address; // Add this line

  // Constructor initializing Turn-specific fields and inheriting from EventDataModel
  Turn({
    required String name,
    required this.eventDateTime,
    this.endDateTime, // Add this line
    required String where,
    required List<String> invitees,
    this.address, // Changed: Now it's an optional field of Turn
    String? description,
    List<String>? moods,
    String? uid,
    String? username,
    String? eventId,
    DateTime? datePublished,
    String? imageUrl,
    String? profilePictureUrl,
    List<String>? organizers,
    List<String>? teamInvitees,
    this.attending = const [],
    this.notSureAttending = const [],
    this.notAttending = const [],
    this.notAnswered = const [],
    String? channelId,
  }) : super(
          name: name,
          where: where,
          description: description ?? '',
          moods: moods ?? [],
          uid: uid ?? '',
          username: username ?? '',
          eventId: eventId ?? '',
          datePublished: datePublished ?? DateTime.now(),
          imageUrl: imageUrl ?? '',
          profilePictureUrl: profilePictureUrl ?? '',
          organizers: organizers ?? [],
          invitees: invitees,
          teamInvitees: teamInvitees ?? [],
          channelId: channelId ?? '',
        );

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
      'endDateTime': endDateTime?.toIso8601String(),
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
      moods: List<String>.from(json['moods'] ?? []),
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      eventId: json['turnId'],
      datePublished: json['datePublished'] != null
          ? DateTime.parse(json['datePublished'])
          : null,
      eventDateTime: DateTime.parse(json['eventDateTime']),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'])
          : null,
      imageUrl: json['turnImageUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      where: json['where'] ?? '',
      address: json['address'],
      organizers: List<String>.from(json['organizers'] ?? []),
      invitees: List<String>.from(json['invitees'] ?? []),
      teamInvitees: List<String>.from(json['teamInvitees'] ?? []),
      attending: List<String>.from(json['attending'] ?? []),
      notSureAttending: List<String>.from(json['notSureAttending'] ?? []),
      notAttending: List<String>.from(json['notAttending'] ?? []),
      notAnswered: List<String>.from(json['notAnswered'] ?? []),
      channelId: json['channelId'],
    );
  }

  factory Turn.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Turn(
      name: snapshot['name'] ?? '',
      description: snapshot['description'],
      moods: List<String>.from(snapshot['moods'] ?? []),
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? '',
      eventId: snapshot['eventId'],
      datePublished: snapshot['datePublished'] != null
          ? (snapshot['datePublished'] as Timestamp).toDate()
          : null,
      eventDateTime: (snapshot['eventDateTime'] as Timestamp).toDate(),
      endDateTime: snapshot['endDateTime'] != null
          ? (snapshot['endDateTime'] as Timestamp).toDate()
          : null,
      imageUrl: snapshot['imageUrl'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      where: snapshot['where'] ?? '',
      address: snapshot['address'],
      organizers: List<String>.from(snapshot['organizers'] ?? []),
      invitees: List<String>.from(snapshot['invitees'] ?? []),
      teamInvitees: List<String>.from(snapshot['teamInvitees'] ?? []),
      attending: List<String>.from(snapshot['attending'] ?? []),
      notSureAttending: List<String>.from(snapshot['notSureAttending'] ?? []),
      notAttending: List<String>.from(snapshot['notAttending'] ?? []),
      notAnswered: List<String>.from(snapshot['notAnswered'] ?? []),
      channelId: snapshot['channelId'],
    );
  }
}
