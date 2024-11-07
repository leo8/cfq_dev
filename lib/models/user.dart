import 'package:cloud_firestore/cloud_firestore.dart';

// Model representing a user in the application
class User {
  final String username; // Username of the user
  final String uid; // Unique user ID
  final String email; // User email address
  final List friends; // List of friends 'uid
  final List teams; // List of teams 'uid
  final String profilePictureUrl; // URL for the user's profile picture
  final String location; // User's location
  final DateTime? birthDate; // Optional birthdate of the user
  bool isActive; // User's active status
  final String searchKey; // Used to facilitate user search
  final List postedTurns; // List of turns 'uid
  final List invitedTurns; // List of turns 'uid
  final List postedCfqs; // List of cfqs 'uid
  final List invitedCfqs; // List of cfqs 'uid
  final List favorites; // List of favorite items
  final List<ConversationInfo> conversations; // List of favorite items
  final String notificationsChannelId;
  final int unreadNotificationsCount;
  final List<Request> requests;

  // Constructor for initializing a User object
  User({
    required this.username,
    required this.uid,
    required this.email,
    required this.friends,
    required this.teams,
    required this.profilePictureUrl,
    required this.location,
    required this.birthDate,
    required this.isActive,
    required this.searchKey,
    required this.postedTurns,
    required this.invitedTurns,
    required this.postedCfqs,
    required this.invitedCfqs,
    required this.favorites,
    required this.conversations,
    required this.notificationsChannelId,
    required this.unreadNotificationsCount,
    required this.requests,
  });

  // Convert User object to a JSON format for storage
  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "friends": friends,
        "teams": teams,
        "profilePictureUrl": profilePictureUrl,
        "location": location,
        "birthDate": birthDate
            ?.toIso8601String(), // Convert birthDate to string if it's not null
        "isActive": isActive,
        "searchKey": searchKey,
        "postedTurns": postedTurns,
        "invitedTurns": invitedTurns,
        "postedCfqs": postedCfqs,
        "invitedCfqs": invitedCfqs,
        "favorites": favorites,
        "conversations": conversations.map((e) => e.toMap()).toList(),
        "notificationsChannelId": notificationsChannelId,
        "unreadNotificationsCount": unreadNotificationsCount,
      };

  // Create a User object from a Firestore snapshot
  factory User.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      friends: snapshot['friends'],
      teams: snapshot['teams'],
      profilePictureUrl: snapshot['profilePictureUrl'],
      location: snapshot['location'],
      birthDate: snapshot['birthDate'] != null
          ? DateTime.parse(snapshot['birthDate'])
          : null, // Parse birthDate if it's not null
      isActive: snapshot['isActive'],
      searchKey: snapshot['searchKey'],
      postedTurns: snapshot['postedTurns'],
      invitedTurns: snapshot['invitedTurns'],
      postedCfqs: snapshot['postedCfqs'],
      invitedCfqs: snapshot['invitedCfqs'],
      favorites: snapshot['favorites'],
      conversations: (snapshot['conversations'] as List<dynamic>?)
              ?.map((e) => ConversationInfo.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationsChannelId: snapshot['notificationsChannelId'],
      unreadNotificationsCount: snapshot['unreadNotificationsCount'] ?? 0,
      requests: (snapshot['requests'] as List<dynamic>?)
              ?.map((e) => Request.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      uid: map['uid'] as String,
      email: map['email'] as String,
      friends: map['friends'] as List<dynamic>,
      teams: map['teams'] as List<dynamic>,
      profilePictureUrl: map['profilePictureUrl'] as String,
      location: map['location'] as String,
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : null,
      isActive: map['isActive'] as bool,
      searchKey: map['searchKey'] as String,
      postedTurns: map['postedTurns'] as List<dynamic>,
      invitedTurns: map['invitedTurns'] as List<dynamic>,
      postedCfqs: map['postedCfqs'] as List<dynamic>,
      invitedCfqs: map['invitedCfqs'] as List<dynamic>,
      favorites: map['favorites'] as List<dynamic>,
      conversations: (map['conversations'] as List<dynamic>?)
              ?.map((e) => ConversationInfo.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationsChannelId: map['notificationsChannelId'] as String,
      unreadNotificationsCount: map['unreadNotificationsCount'] as int,
      requests: (map['requests'] as List<dynamic>?)
              ?.map((e) => Request.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "uid": uid,
      "email": email,
      "friends": friends,
      "teams": teams,
      "profilePictureUrl": profilePictureUrl,
      "location": location,
      "birthDate": birthDate?.toIso8601String(),
      "isActive": isActive,
      "searchKey": searchKey,
      "postedTurns": postedTurns,
      "invitedTurns": invitedTurns,
      "postedCfqs": postedCfqs,
      "invitedCfqs": invitedCfqs,
      "favorites": favorites,
      "conversations": conversations.map((e) => e.toMap()).toList(),
      "notificationsChannelId": notificationsChannelId,
      "unreadNotificationsCount": unreadNotificationsCount,
    };
  }
}

class ConversationInfo {
  final String conversationId;
  int unreadMessagesCount;

  ConversationInfo({
    required this.conversationId,
    this.unreadMessagesCount = 0,
  });

  factory ConversationInfo.fromMap(Map<String, dynamic> map) {
    return ConversationInfo(
      conversationId: map['conversationId'] as String,
      unreadMessagesCount: map['unreadMessagesCount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'unreadMessagesCount': unreadMessagesCount,
    };
  }
}

enum RequestType {
  team,
  friend,
}

enum RequestStatus {
  pending,
  accepted,
  denied,
}

class Request {
  final String id;
  final RequestType type;
  final String requesterId;
  final String requesterUsername;
  final String requesterProfilePictureUrl;
  final String? teamId;
  final String? teamName;
  final String? teamImageUrl;
  final DateTime timestamp;
  final RequestStatus status;

  Request({
    required this.id,
    required this.type,
    required this.requesterId,
    required this.requesterUsername,
    required this.requesterProfilePictureUrl,
    this.teamId,
    this.teamName,
    this.teamImageUrl,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'requesterId': requesterId,
        'requesterUsername': requesterUsername,
        'requesterProfilePictureUrl': requesterProfilePictureUrl,
        'teamId': teamId,
        'teamName': teamName,
        'teamImageUrl': teamImageUrl,
        'timestamp': timestamp.toIso8601String(),
        'status': status.toString().split('.').last,
      };

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      type: RequestType.values
          .firstWhere((t) => t.toString().split('.').last == json['type']),
      requesterId: json['requesterId'],
      requesterUsername: json['requesterUsername'],
      requesterProfilePictureUrl: json['requesterProfilePictureUrl'],
      teamId: json['teamId'],
      teamName: json['teamName'],
      teamImageUrl: json['teamImageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      status: RequestStatus.values
          .firstWhere((s) => s.toString().split('.').last == json['status']),
    );
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'],
      type: RequestType.values
          .firstWhere((t) => t.toString().split('.').last == map['type']),
      requesterId: map['requesterId'],
      requesterUsername: map['requesterUsername'],
      requesterProfilePictureUrl: map['requesterProfilePictureUrl'],
      teamId: map['teamId'],
      teamName: map['teamName'],
      teamImageUrl: map['teamImageUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      status: RequestStatus.values
          .firstWhere((s) => s.toString().split('.').last == map['status']),
    );
  }

  factory Request.empty() {
    return Request(
      id: '',
      type: RequestType.friend,
      requesterId: '',
      requesterUsername: '',
      requesterProfilePictureUrl: '',
      timestamp: DateTime.now(),
      status: RequestStatus.pending,
    );
  }
}
