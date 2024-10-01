import 'event_data_model.dart';

class Cfq extends EventDataModel {
  final List<String> followers;         // List of followers of the CFQ

  Cfq({
    required this.followers,
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
    required super.comments,
  });

  // Convert Cfq object to JSON format
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
      'followers': followers,
      'comments': comments, // Included comments in toJson
    };
  }

  // Convert JSON to Cfq object
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
      followers: List<String>.from(json['followers']),
      comments: List<String>.from(json['comments'] ?? []), // Included comments in fromJson
    );
  }
}
