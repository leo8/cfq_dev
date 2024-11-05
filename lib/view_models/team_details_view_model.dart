import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/conversation_service.dart';
import '../models/notification.dart' as model;
import 'package:uuid/uuid.dart';

class TeamDetailsViewModel extends ChangeNotifier {
  Team _team;
  List<model.User> _members = [];
  bool _isLoading = true;
  bool _hasChanges = false;
  bool _isCurrentUserActive = false;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ConversationService _conversationService = ConversationService();

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;
  bool get isCurrentUserActive => _isCurrentUserActive;

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];

  List<Conversation> get filteredConversations => _filteredConversations;

  final BehaviorSubject<int> _unreadConversationsCountSubject =
      BehaviorSubject<int>.seeded(0);
  Stream<int> get unreadConversationsCountStream =>
      _unreadConversationsCountSubject.stream;

  TeamDetailsViewModel({required Team team}) : _team = team {
    _initializeCurrentUser();
    _fetchTeamMembers();
    _listenToCurrentUserActiveStatus();
  }

  Team get team => _team;
  List<model.User> get members => _members;

  Future<void> _initializeCurrentUser() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      _currentUser = model.User.fromSnap(userDoc);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing current user: $e');
    }
  }

  Future<void> _fetchTeamMembers() async {
    try {
      _isLoading = true;
      notifyListeners();

      List<model.User> fetchedMembers = [];
      for (var i = 0; i < team.members.length; i += 10) {
        var end = (i + 10 < team.members.length) ? i + 10 : team.members.length;
        var batch = team.members.sublist(i, end);

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: batch)
            .get();

        fetchedMembers.addAll(
            snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList());
      }

      _members = fetchedMembers;
      sortMembersWithCurrentUserFirst();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching team members: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTeamDetails() async {
    _isLoading = true;
    notifyListeners();

    DocumentSnapshot teamDoc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(_team.uid)
        .get();
    Team newTeam = Team.fromSnap(teamDoc);
    if (_team != newTeam) {
      _team = newTeam;
      _hasChanges = true;
    }
    await _fetchTeamMembers();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> leaveTeam() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Remove user from team
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(_team.uid)
          .update({
        'members': FieldValue.arrayRemove([currentUserId])
      });

      // Remove team from user's teams
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'teams': FieldValue.arrayRemove([_team.uid])
      });

      // Update local team object
      _team.members.remove(currentUserId);
      _members.removeWhere((member) => member.uid == currentUserId);

      _hasChanges = true;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Error leaving team: $e');
      return false;
    }
  }

  void sortMembersWithCurrentUserFirst() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _members.sort((a, b) {
      if (a.uid == currentUserId) return -1;
      if (b.uid == currentUserId) return 1;
      return 0;
    });
    notifyListeners();
  }

  void _listenToCurrentUserActiveStatus() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        _isCurrentUserActive = snapshot.data()?['isActive'] ?? false;

        // Add this section to update favorites
        if (_currentUser != null) {
          _currentUser!.favorites.clear();
          _currentUser!.favorites
              .addAll(List<String>.from(userData['favorites'] ?? []));
        }

        notifyListeners();
      }
    });
  }

  /// Fetches both "turn" and "cfq" collections from Firestore for the team,
  /// combines them into a single stream, and sorts them by date.
  Stream<List<DocumentSnapshot>> fetchTeamCombinedEvents() {
    try {
      return FirebaseFirestore.instance
          .collection('teams')
          .doc(_team.uid)
          .snapshots()
          .switchMap((teamSnapshot) {
        if (!teamSnapshot.exists) {
          AppLogger.warning(
              "Team document does not exist for uid: ${_team.uid}");
          return Stream.value(<DocumentSnapshot>[]);
        }

        final teamData = teamSnapshot.data() as Map<String, dynamic>;
        final teamInvitedCfqs =
            List<String>.from(teamData['invitedCfqs'] ?? []);
        final teamInvitedTurns =
            List<String>.from(teamData['invitedTurns'] ?? []);

        AppLogger.debug(
            "Team Invited CFQs: ${teamInvitedCfqs.length}, Team Invited Turns: ${teamInvitedTurns.length}");

        // Handle empty lists
        Stream<List<DocumentSnapshot>> cfqsStream = teamInvitedCfqs.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: teamInvitedCfqs)
                .snapshots()
                .map((snapshot) {
                AppLogger.debug("Fetched ${snapshot.docs.length} Team CFQs");
                return snapshot.docs;
              });

        Stream<List<DocumentSnapshot>> turnsStream = teamInvitedTurns.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('turns')
                .where(FieldPath.documentId, whereIn: teamInvitedTurns)
                .snapshots()
                .map((snapshot) {
                AppLogger.debug("Fetched ${snapshot.docs.length} Team Turns");
                return snapshot.docs;
              });

        return Rx.combineLatest2(
          cfqsStream,
          turnsStream,
          (List<DocumentSnapshot> cfqs, List<DocumentSnapshot> turns) {
            List<DocumentSnapshot> allEvents = [...cfqs, ...turns];
            AppLogger.debug(
                "Combined team events: ${allEvents.length} (${cfqs.length} CFQs + ${turns.length} Turns)");

            if (allEvents.isEmpty) {
              return allEvents;
            }

            try {
              allEvents.sort((a, b) {
                DateTime dateA = getPublishedDateTime(a);
                DateTime dateB = getPublishedDateTime(b);
                AppLogger.debug("Comparing dates - A: $dateA, B: $dateB");
                return dateB.compareTo(dateA);
              });
            } catch (e) {
              AppLogger.error("Error sorting events: $e");
            }

            return allEvents;
          },
        );
      });
    } catch (error) {
      AppLogger.error("Error in fetchTeamCombinedEvents: $error");
      return Stream.value([]);
    }
  }

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate(); // Convert Firestore Timestamp to DateTime
    } else if (date is String) {
      try {
        return DateTime.parse(date); // Parse String to DateTime
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date as DateTime: $date");
        return DateTime.now(); // Fallback to the current date
      }
    } else if (date is DateTime) {
      return date; // Already a DateTime, return as is
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now(); // Fallback to the current date
    }
  }

  DateTime getEventDateTime(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime result;
    if (doc.reference.parent.id == 'turns') {
      result = parseDate(data['eventDateTime']);
    } else {
      result = data['eventDateTime'] != null
          ? parseDate(data['eventDateTime'])
          : parseDate(data['datePublished']);
    }
    return result;
  }

  DateTime getPublishedDateTime(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime result;
    result = parseDate(data['datePublished']);
    return result;
  }

  // Event interaction methods
  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

      if (isFavorite) {
        // Add to favorites
        await userRef.update({
          'favorites': FieldValue.arrayUnion([eventId])
        });
      } else {
        // Remove from favorites
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
      }

      // Update local user object
      if (_currentUser != null) {
        if (isFavorite) {
          _currentUser!.favorites.add(eventId);
        } else {
          _currentUser!.favorites.remove(eventId);
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
    }
  }

  Stream<String> attendingStatusStream(String turnId, String userId) {
    return FirebaseFirestore.instance
        .collection('turns')
        .doc(turnId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 'notAnswered';
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['attending']?.contains(userId) ?? false) return 'attending';
      if (data['notSureAttending']?.contains(userId) ?? false)
        return 'notSureAttending';
      if (data['notAttending']?.contains(userId) ?? false)
        return 'notAttending';
      return 'notAnswered';
    });
  }

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final turnDoc = await transaction.get(turnRef);
        final userDoc = await transaction.get(userRef);

        if (!turnDoc.exists || !userDoc.exists) {
          throw Exception('Turn or User document does not exist');
        }

        Map<String, dynamic> turnData = turnDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Remove user from all attending lists
        ['attending', 'notSureAttending', 'notAttending', 'notAnswered']
            .forEach((field) {
          if (turnData[field] != null) {
            turnData[field] = (turnData[field] as List)
                .where((id) => id != currentUser!.uid)
                .toList();
          }
        });

        // Add user to the appropriate list
        if (status != 'notAnswered') {
          turnData[status] = [...(turnData[status] ?? []), currentUser!.uid];
        }

        // Update user's attending status for this turn
        if (userData['attendingStatus'] == null) {
          userData['attendingStatus'] = {};
        }
        userData['attendingStatus'][turnId] = status;

        // Create notification only when status is 'attending'
        if (status == 'attending') {
          await _createAttendingNotification(turnId);
        }

        transaction.update(turnRef, turnData);
        transaction.update(userRef, userData);
      });

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating attending status: $e');
    }
  }

  Stream<int> attendingCountStream(String turnId) {
    return _firestore
        .collection('turns')
        .doc(turnId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['attending'] as List?)?.length ?? 0;
    });
  }

  Stream<bool> isFollowingUpStream(String cfqId, String userId) {
    return _firestore.collection('cfqs').doc(cfqId).snapshots().map((snapshot) {
      List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
      return followingUp.contains(userId);
    });
  }

  Future<void> toggleFollowUp(String cfqId, String userId) async {
    try {
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
      List<dynamic> followingUp = data['followingUp'] ?? [];

      bool isNowFollowing = !followingUp.contains(userId);

      if (isNowFollowing) {
        await addFollowUp(cfqId, userId);
        await _createFollowUpNotification(cfqId);
      } else {
        await removeFollowUp(cfqId, userId);
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
    }
  }

  static Future<void> addFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      AppLogger.error('Error adding follow-up: $e');
      rethrow;
    }
  }

  static Future<void> removeFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      AppLogger.error('Error removing follow-up: $e');
      rethrow;
    }
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(
        currentUser!.uid, channelId);
    await loadConversations();
    notifyListeners();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUser!.uid, channelId);
    await loadConversations();
    notifyListeners();
  }

  Future<void> resetUnreadMessages(String conversationId) async {
    try {
      await _conversationService.resetUnreadMessages(
          currentUser!.uid, conversationId);
      // Update the local state
      int index = currentUser!.conversations
          .indexWhere((conv) => conv.conversationId == conversationId);
      if (index != -1) {
        currentUser!.conversations[index].unreadMessagesCount = 0;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error resetting unread messages: $e');
    }
  }

  Future<void> loadConversations() async {
    _conversations =
        await _conversationService.getUserConversations(currentUser!.uid);
    _sortConversations();
    _filteredConversations = _conversations;
    notifyListeners();
  }

  void _sortConversations() {
    _conversations.sort(
        (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
  }

  Future<void> _createFollowUpNotification(String cfqId) async {
    try {
      if (_currentUser == null) return;

      // Get the CFQ document to get the organizer's ID and name
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> cfqData = cfqSnapshot.data() as Map<String, dynamic>;
      String organizerId = cfqData['uid'] as String;
      String cfqName = cfqData['cfqName'] as String;

      // Get the organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(organizerId).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': model.NotificationType.followUp.toString().split('.').last,
        'content': {
          'cfqId': cfqId,
          'cfqName': cfqName,
          'followerId': _currentUser!.uid,
          'followerUsername': _currentUser!.username,
          'followerProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification to organizer's notification channel
      await _firestore
          .collection('notifications')
          .doc(organizerNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count for the organizer
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating follow-up notification: $e');
    }
  }

  Future<void> _createAttendingNotification(String turnId) async {
    try {
      if (_currentUser == null) return;

      // Get the turn document to get the organizer's ID and name
      DocumentSnapshot turnSnapshot =
          await _firestore.collection('turns').doc(turnId).get();
      Map<String, dynamic> turnData =
          turnSnapshot.data() as Map<String, dynamic>;
      String organizerId = turnData['uid'] as String;
      String turnName = turnData['turnName'] as String;

      // Get the organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(organizerId).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': model.NotificationType.attending.toString().split('.').last,
        'content': {
          'turnId': turnId,
          'turnName': turnName,
          'attendingId': _currentUser!.uid,
          'attendingUsername': _currentUser!.username,
          'attendingProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification to organizer's notification channel
      await _firestore
          .collection('notifications')
          .doc(organizerNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count for the organizer
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating attending notification: $e');
    }
  }
}
