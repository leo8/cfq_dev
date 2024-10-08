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

  EventDataModel({
    required this.name,
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
  });
}
