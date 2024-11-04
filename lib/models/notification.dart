import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to define different notification types
enum NotificationType {
  message,
  teamInvite,
  followUp,
  eventParticipation,
  friendRequest,
  eventInvitation,
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

  EventInvitationNotificationContent({
    required this.eventId,
    required this.eventName,
    required this.eventImageUrl,
    required this.organizerId,
    required this.organizerUsername,
    required this.organizerProfilePictureUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventName': eventName,
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
      eventImageUrl: json['eventImageUrl'] as String,
      organizerId: json['organizerId'] as String,
      organizerUsername: json['organizerUsername'] as String,
      organizerProfilePictureUrl: json['organizerProfilePictureUrl'] as String,
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
    var snapshot = snap.data() as Map<String, dynamic>;

    // Convert the string type to enum
    NotificationType type = NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == snapshot['type'],
      orElse: () =>
          throw Exception('Unknown notification type: ${snapshot['type']}'),
    );

    // Handle timestamp
    DateTime timestamp;
    var timestampData = snapshot['timestamp'];
    if (timestampData is Timestamp) {
      timestamp = timestampData.toDate();
    } else if (timestampData is String) {
      timestamp = DateTime.parse(timestampData);
    } else {
      throw Exception('Invalid timestamp format');
    }

    NotificationContent content;
    switch (type) {
      case NotificationType.message:
        var contentData = Map<String, dynamic>.from(snapshot['content']);
        // Convert Timestamp to String for MessageNotificationContent
        if (contentData['timestampSent'] is Timestamp) {
          contentData['timestampSent'] =
              (contentData['timestampSent'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }
        content = MessageNotificationContent.fromJson(contentData);
        break;
      case NotificationType.eventInvitation:
        content = EventInvitationNotificationContent.fromJson(
            Map<String, dynamic>.from(snapshot['content']));
        break;
      default:
        throw Exception('Unhandled notification type: $type');
    }

    return Notification(
      id: snapshot['id'],
      timestamp: timestamp,
      type: type,
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
