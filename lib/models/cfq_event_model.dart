import 'event_data_model.dart';

// Model for representing a CFQ (event) that extends EventDataModel
class Cfq extends EventDataModel {
  final String when; // When parameter

  // Constructor to initialize CFQ properties
  Cfq({
    required this.when,
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
    required super.invitees,
    required super.teamInvitees,
  });

  // Convert CFQ object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'cfqName': name,
      'description': description,
      'moods': moods,
      'uid': uid,
      'username': username,
      'cfqId': eventId,
      'datePublished': datePublished.toIso8601String(),
      'cfqImageUrl': imageUrl,
      'profilePictureUrl': profilePictureUrl,
      'where': where,
      'organizers': organizers,
      'when': when,
      'invitees': invitees,
      'teamInvitees': teamInvitees,
    };
  }

  // Create a CFQ object from a JSON map
  static Cfq fromJson(Map<String, dynamic> json) {
    return Cfq(
      name: json['cfqName'],
      description: json['description'],
      moods: json['moods'],
      uid: json['uid'],
      username: json['username'],
      eventId: json['cfqId'],
      datePublished: DateTime.parse(json['datePublished']),
      imageUrl: json['cfqImageUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      where: json['where'],
      organizers: List<String>.from(json['organizers']),
      when: json['when'],
      invitees: List<String>.from(json['invitees']),
      teamInvitees: List<String>.from(json['teamInvitees']),
    );
  }
}
