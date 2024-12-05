import 'event_data_model.dart';

// Model for representing a CFQ (event) that extends EventDataModel
class Cfq extends EventDataModel {
  final String when; // When parameter
  final List<String> followingUp; // New field
  final DateTime? eventDateTime; // New optional field
  final DateTime? endDateTime; // Add this field
  final Location? location; // Add location field

  // Constructor to initialize CFQ properties
  Cfq({
    required this.when,
    required List<String> invitees,
    this.followingUp = const [],
    this.eventDateTime,
    this.endDateTime,
    this.location,
    String? description,
    List<String>? moods,
    String? uid,
    String? username,
    String? eventId,
    DateTime? datePublished,
    String? imageUrl,
    String? profilePictureUrl,
    String? where,
    List<String>? organizers,
    List<String>? teamInvitees,
    String? channelId,
  }) : super(
          name: 'ÇFQ ${when.toUpperCase()} ?',
          description: description ?? '',
          moods: moods ?? [],
          uid: uid ?? '',
          username: username ?? '',
          eventId: eventId ?? '',
          datePublished: datePublished ?? DateTime.now(),
          imageUrl: imageUrl ?? '',
          profilePictureUrl: profilePictureUrl ?? '',
          where: where ?? '',
          organizers: organizers ?? [],
          invitees: invitees,
          teamInvitees: teamInvitees ?? [],
          channelId: channelId ?? '',
        );

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
      'location': location?.toJson(), // Add location to JSON
      'organizers': organizers,
      'when': when,
      'invitees': invitees,
      'teamInvitees': teamInvitees,
      'channelId': channelId,
      'followingUp': followingUp,
      'eventDateTime': eventDateTime?.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
    };
  }

  // Create a CFQ object from a JSON map
  factory Cfq.fromJson(Map<String, dynamic> json) {
    return Cfq(
      when: json['when'] ?? '',
      followingUp: List<String>.from(json['followingUp'] ?? []),
      eventDateTime: json['eventDateTime'] != null
          ? DateTime.parse(json['eventDateTime'])
          : null,
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'])
          : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      description: json['description'] ?? '',
      moods: List<String>.from(json['moods'] ?? []),
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      eventId: json['cfqId'] ?? '',
      datePublished: DateTime.parse(json['datePublished']),
      imageUrl: json['cfqImageUrl'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      where: json['where'] ?? '',
      organizers: List<String>.from(json['organizers'] ?? []),
      invitees: List<String>.from(json['invitees'] ?? []),
      teamInvitees: List<String>.from(json['teamInvitees'] ?? []),
      channelId: json['channelId'] ?? '',
    );
  }
}
