import 'event_data_model.dart';

// Model for representing a CFQ (event) that extends EventDataModel
class Cfq extends EventDataModel {
  final String when; // When parameter
  final List<String> followingUp; // New field

  // Constructor to initialize CFQ properties
  Cfq(
      {required this.when,
      required this.followingUp,
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
      required super.channelId});

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
      'channelId': channelId,
      'followingUp': followingUp,
    };
  }

  // Create a CFQ object from a JSON map
  factory Cfq.fromJson(Map<String, dynamic> json) {
    return Cfq(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      moods: List<String>.from(json['moods'] ?? []),
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      followingUp: List<String>.from(json['followingUp'] ?? []),
      eventId: json['eventId'] ?? '',
      datePublished: DateTime.parse(json['datePublished']),
      when: json['when'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      where: json['where'] ?? '',
      organizers: List<String>.from(json['organizers'] ?? []),
      invitees: List<String>.from(json['invitees'] ?? []),
      teamInvitees: List<String>.from(json['teamInvitees'] ?? []),
      channelId: json['channelId'] ?? '',
    );
  }
}
