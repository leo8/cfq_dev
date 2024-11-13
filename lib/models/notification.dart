import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

// Enum to define different notification types
enum NotificationType {
  message,
  teamRequest,
  followUp,
  friendRequest,
  eventInvitation,
  attending,
  acceptedTeamRequest,
  acceptedFriendRequest,
}

// Base class for notification content
abstract class NotificationContent {
  Map<String, dynamic> toJson();
}

// Message specific notification content
class MessageNotificationContent extends NotificationContent {
  final String senderProfilePictureUrl;
  final String messageContent;
  final DateTime timestampSent;
  final String senderUsername;
  final String conversationId;

  MessageNotificationContent({
    required this.senderProfilePictureUrl,
    required this.messageContent,
    required this.timestampSent,
    required this.senderUsername,
    required this.conversationId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'senderProfilePictureUrl': senderProfilePictureUrl,
        'messageContent': messageContent,
        'timestampSent': timestampSent.toIso8601String(),
        'senderUsername': senderUsername,
        'conversationId': conversationId,
      };

  factory MessageNotificationContent.fromJson(Map<String, dynamic> json) {
    return MessageNotificationContent(
      senderProfilePictureUrl: json['senderProfilePictureUrl'],
      messageContent: json['messageContent'],
      timestampSent: DateTime.parse(json['timestampSent']),
      senderUsername: json['senderUsername'],
      conversationId: json['conversationId'],
    );
  }
}

// Event invitation specific notification content
class EventInvitationNotificationContent extends NotificationContent {
  final String eventId;
  final String eventName;
  final String eventImageUrl;
  final String organizerId;
  final String organizerUsername;
  final String organizerProfilePictureUrl;
  final bool isTurn;

  EventInvitationNotificationContent({
    required this.eventId,
    required this.eventName,
    required this.eventImageUrl,
    required this.organizerId,
    required this.organizerUsername,
    required this.organizerProfilePictureUrl,
    required this.isTurn,
  });

  @override
  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventName': eventName,
        'isTurn': isTurn,
        'eventImageUrl': eventImageUrl,
        'organizerId': organizerId,
        'organizerUsername': organizerUsername,
        'organizerProfilePictureUrl': organizerProfilePictureUrl,
      };

  factory EventInvitationNotificationContent.fromJson(
      Map<String, dynamic> json) {
    return EventInvitationNotificationContent(
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      isTurn: json['isTurn'] as bool,
      eventImageUrl: json['eventImageUrl'] as String,
      organizerId: json['organizerId'] as String,
      organizerUsername: json['organizerUsername'] as String,
      organizerProfilePictureUrl: json['organizerProfilePictureUrl'] as String,
    );
  }
}

// Follow up specific notification content
class FollowUpNotificationContent extends NotificationContent {
  final String cfqId;
  final String cfqName;
  final String followerId;
  final String followerUsername;
  final String followerProfilePictureUrl;

  FollowUpNotificationContent({
    required this.cfqId,
    required this.cfqName,
    required this.followerId,
    required this.followerUsername,
    required this.followerProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'cfqId': cfqId,
        'cfqName': cfqName,
        'followerId': followerId,
        'followerUsername': followerUsername,
        'followerProfilePictureUrl': followerProfilePictureUrl,
      };

  factory FollowUpNotificationContent.fromJson(Map<String, dynamic> json) {
    return FollowUpNotificationContent(
      cfqId: json['cfqId'] as String,
      cfqName: json['cfqName'] as String,
      followerId: json['followerId'] as String,
      followerUsername: json['followerUsername'] as String,
      followerProfilePictureUrl: json['followerProfilePictureUrl'] as String,
    );
  }
}

// Attending specific notification content
class AttendingNotificationContent extends NotificationContent {
  final String turnId;
  final String turnName;
  final String attendingId;
  final String attendingUsername;
  final String attendingProfilePictureUrl;

  AttendingNotificationContent({
    required this.turnId,
    required this.turnName,
    required this.attendingId,
    required this.attendingUsername,
    required this.attendingProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'turnId': turnId,
        'turnName': turnName,
        'attendingId': attendingId,
        'attendingUsername': attendingUsername,
        'attendingProfilePictureUrl': attendingProfilePictureUrl,
      };

  factory AttendingNotificationContent.fromJson(Map<String, dynamic> json) {
    return AttendingNotificationContent(
      turnId: json['turnId'] as String,
      turnName: json['turnName'] as String,
      attendingId: json['attendingId'] as String,
      attendingUsername: json['attendingUsername'] as String,
      attendingProfilePictureUrl: json['attendingProfilePictureUrl'] as String,
    );
  }
}

// Team request specific notification content
class TeamRequestNotificationContent extends NotificationContent {
  final String teamId;
  final String teamName;
  final String teamImageUrl;
  final String inviterId;
  final String inviterUsername;
  final String inviterProfilePictureUrl;

  TeamRequestNotificationContent({
    required this.teamId,
    required this.teamName,
    required this.teamImageUrl,
    required this.inviterId,
    required this.inviterUsername,
    required this.inviterProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'teamName': teamName,
        'teamImageUrl': teamImageUrl,
        'inviterId': inviterId,
        'inviterUsername': inviterUsername,
        'inviterProfilePictureUrl': inviterProfilePictureUrl,
      };

  factory TeamRequestNotificationContent.fromJson(Map<String, dynamic> json) {
    return TeamRequestNotificationContent(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamImageUrl: json['teamImageUrl'] as String,
      inviterId: json['inviterId'] as String,
      inviterUsername: json['inviterUsername'] as String,
      inviterProfilePictureUrl: json['inviterProfilePictureUrl'] as String,
    );
  }
}

// Friend request specific notification content
class FriendRequestNotificationContent extends NotificationContent {
  final String requesterId;
  final String requesterUsername;
  final String requesterProfilePictureUrl;

  FriendRequestNotificationContent({
    required this.requesterId,
    required this.requesterUsername,
    required this.requesterProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'requesterId': requesterId,
        'requesterUsername': requesterUsername,
        'requesterProfilePictureUrl': requesterProfilePictureUrl,
      };

  factory FriendRequestNotificationContent.fromJson(Map<String, dynamic> json) {
    return FriendRequestNotificationContent(
      requesterId: json['requesterId'] as String,
      requesterUsername: json['requesterUsername'] as String,
      requesterProfilePictureUrl: json['requesterProfilePictureUrl'] as String,
    );
  }
}

// Accepted team request specific notification content
class AcceptedTeamRequestNotificationContent extends NotificationContent {
  final String teamId;
  final String teamName;
  final String teamImageUrl;
  final String accepterId;
  final String accepterUsername;
  final String accepterProfilePictureUrl;

  AcceptedTeamRequestNotificationContent({
    required this.teamId,
    required this.teamName,
    required this.teamImageUrl,
    required this.accepterId,
    required this.accepterUsername,
    required this.accepterProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'teamName': teamName,
        'teamImageUrl': teamImageUrl,
        'accepterId': accepterId,
        'accepterUsername': accepterUsername,
        'accepterProfilePictureUrl': accepterProfilePictureUrl,
      };

  factory AcceptedTeamRequestNotificationContent.fromJson(
      Map<String, dynamic> json) {
    return AcceptedTeamRequestNotificationContent(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamImageUrl: json['teamImageUrl'] as String,
      accepterId: json['accepterId'] as String,
      accepterUsername: json['accepterUsername'] as String,
      accepterProfilePictureUrl: json['accepterProfilePictureUrl'] as String,
    );
  }
}

// Accepted friend request specific notification content
class AcceptedFriendRequestNotificationContent extends NotificationContent {
  final String accepterId;
  final String accepterUsername;
  final String accepterProfilePictureUrl;

  AcceptedFriendRequestNotificationContent({
    required this.accepterId,
    required this.accepterUsername,
    required this.accepterProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'accepterId': accepterId,
        'accepterUsername': accepterUsername,
        'accepterProfilePictureUrl': accepterProfilePictureUrl,
      };

  factory AcceptedFriendRequestNotificationContent.fromJson(
      Map<String, dynamic> json) {
    return AcceptedFriendRequestNotificationContent(
      accepterId: json['accepterId'] as String,
      accepterUsername: json['accepterUsername'] as String,
      accepterProfilePictureUrl: json['accepterProfilePictureUrl'] as String,
    );
  }
}

// Main notification class
class Notification {
  final String id;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationContent content;

  Notification({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.content,
  });

  factory Notification.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    final contentData = data['content'] as Map<String, dynamic>;
    final typeStr = data['type'] as String;

    NotificationContent content;
    switch (typeStr) {
      case 'message':
        content = MessageNotificationContent.fromJson(contentData);
        break;
      case 'eventInvitation':
        content = EventInvitationNotificationContent.fromJson(contentData);
        break;
      case 'followUp':
        content = FollowUpNotificationContent.fromJson(contentData);
        break;
      case 'attending':
        content = AttendingNotificationContent.fromJson(contentData);
        break;
      case 'teamRequest':
        content = TeamRequestNotificationContent.fromJson(contentData);
        break;
      case 'friendRequest':
        content = FriendRequestNotificationContent.fromJson(contentData);
        break;
      case 'acceptedTeamRequest':
        content = AcceptedTeamRequestNotificationContent.fromJson(contentData);
        break;
      case 'acceptedFriendRequest':
        content =
            AcceptedFriendRequestNotificationContent.fromJson(contentData);
        break;
      default:
        throw Exception('Unknown notification type: $typeStr');
    }

    // Convert Firestore Timestamp to DateTime
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      timestamp = DateTime.parse(data['timestamp']);
    } else {
      timestamp = DateTime.now(); // Fallback
      AppLogger.error(
          'Unexpected timestamp type: ${data['timestamp'].runtimeType}');
    }

    return Notification(
      id: data['id'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.toString().split('.').last == typeStr,
      ),
      timestamp: timestamp,
      content: content,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.toString().split('.').last,
        'content': content.toJson(),
      };
}
