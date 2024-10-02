import '../models/user.dart' as model;

class Team {
  final String id;
  final String name;
  final String imageUrl;
  final List<model.User> members;

  Team({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.members,
  });
}