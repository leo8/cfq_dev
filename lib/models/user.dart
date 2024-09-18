class User {
  final String username;
  final String uid;
  final String bio;
  final String email;
  final List followers;
  final List following;
  final String profilePictureUrl;

  const User({
    required this.username,
    required this.uid,
    required this.bio,
    required this.email,
    required this.followers,
    required this.following,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "bio": bio,
        "email": email,
        "followers": followers,
        "following": following,
        "profilePictureUrl": profilePictureUrl,
      };
}