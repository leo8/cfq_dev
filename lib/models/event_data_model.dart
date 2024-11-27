class EventDataModel {
  final String name;
  final String description;
  final List<String> moods;
  final String uid;
  final String username;
  final String eventId;
  final DateTime datePublished;
  final String imageUrl;
  final String where;
  final List<String> organizers;
  final String profilePictureUrl;
  final List<String> teamInvitees;
  final List<String> invitees;
  final String channelId;

  EventDataModel(
      {required this.name,
      required this.description,
      required this.moods,
      required this.uid,
      required this.username,
      required this.eventId,
      required this.datePublished,
      required this.imageUrl,
      required this.profilePictureUrl,
      required this.where,
      required this.organizers,
      required this.teamInvitees,
      required this.invitees,
      required this.channelId});

  Map<String, dynamic> toJson() => {
        'name': name,
        'where': where,
        'description': description,
        'moods': moods,
        'uid': uid,
        'username': username,
        'eventId': eventId,
        'datePublished': datePublished.toIso8601String(),
        'imageUrl': imageUrl,
        'profilePictureUrl': profilePictureUrl,
        'organizers': organizers,
        'invitees': invitees,
        'teamInvitees': teamInvitees,
        'channelId': channelId,
      };
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}
