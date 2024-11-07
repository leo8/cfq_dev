import 'dart:async';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../providers/conversation_service.dart';
import 'package:uuid/uuid.dart';
import '../models/notification.dart' as notificationModel;

class ThreadViewModel extends ChangeNotifier {
  final String currentUserUid;
  final TextEditingController searchController = TextEditingController();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _debounce;

  List<model.User> _users = [];
  List<model.User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  Stream<DocumentSnapshot>? _currentUserStream;
  Stream<DocumentSnapshot>? get currentUserStream => _currentUserStream;

  Stream<List<model.User>>? _activeFriendsStream;
  Stream<List<model.User>>? get activeFriendsStream => _activeFriendsStream;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];

  List<Conversation> get filteredConversations => _filteredConversations;

  final BehaviorSubject<int> _unreadConversationsCountSubject =
      BehaviorSubject<int>.seeded(0);
  Stream<int> get unreadConversationsCountStream =>
      _unreadConversationsCountSubject.stream;

  final BehaviorSubject<int> _unreadNotificationsCountSubject =
      BehaviorSubject<int>.seeded(0);
  Stream<int> get unreadNotificationsCountStream =>
      _unreadNotificationsCountSubject.stream;

  ThreadViewModel({required this.currentUserUid}) {
    searchController.addListener(_onSearchChanged);
    _initializeData();
    _listenToUserChanges();
    loadConversations();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _userSubscription?.cancel();
    _unreadConversationsCountSubject.close();
    _unreadNotificationsCountSubject.close();
    super.dispose();
  }

  Stream<bool> isFollowingUpStream(String cfqId, String userId) {
    return _firestore.collection('cfqs').doc(cfqId).snapshots().map((snapshot) {
      List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
      return followingUp.contains(userId);
    });
  }

  Future<void> _initializeData() async {
    await _fetchCurrentUser();
    _setupActiveFriendsStream();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      DocumentSnapshot currentUserSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      _currentUser = model.User.fromSnap(currentUserSnap);
      _currentUserStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .snapshots();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching current user: $e');
    }
  }

  void _setupActiveFriendsStream() {
    if (_currentUser == null || _currentUser!.friends.isEmpty) {
      _activeFriendsStream = Stream.value([]);
      return;
    }

    _activeFriendsStream = FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: _currentUser!.friends)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();
    });
  }

  Future<void> updateIsActiveStatus(bool newValue) async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'isActive': newValue});

      _currentUser!.isActive = newValue;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating active status: $e');
    }
  }

  Future<void> performSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot;
      if (query.isEmpty) {
        // Fetch all users when the query is empty
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .limit(
                20) // Limit the number of results to avoid performance issues
            .get();
      } else {
        // Existing search logic for non-empty queries
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('searchKey', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('searchKey',
                isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .get();
      }

      List<model.User> users =
          snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();
      _users = users.where((user) => user.uid != currentUserUid).toList();
    } catch (e) {
      AppLogger.error('Error while searching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isConversationInUserList(String channelId) async {
    return await _conversationService.isConversationInUserList(
        currentUserUid, channelId);
  }

  /// Parses different types of date formats (Timestamp, String, DateTime).
  /// Falls back to the current date if the format is unrecognized.
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

  /// Fetches both "turn" and "cfq" collections from Firestore,
  /// combines them into a single stream, and sorts them by date.
  Stream<List<DocumentSnapshot>> fetchCombinedEvents() {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .snapshots()
          .switchMap((userSnapshot) {
        if (!userSnapshot.exists) {
          AppLogger.warning(
              "User document does not exist for uid: $currentUserUid");
          return Stream.value(<DocumentSnapshot>[]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final invitedCfqs = List<String>.from(userData['invitedCfqs'] ?? []);
        final invitedTurns = List<String>.from(userData['invitedTurns'] ?? []);

        AppLogger.debug(
            "Invited CFQs: ${invitedCfqs.length}, Invited Turns: ${invitedTurns.length}");

        // Handle empty lists
        Stream<List<DocumentSnapshot>> cfqsStream = invitedCfqs.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: invitedCfqs)
                .snapshots()
                .map((snapshot) {
                AppLogger.debug("Fetched ${snapshot.docs.length} CFQs");
                return snapshot.docs;
              });

        Stream<List<DocumentSnapshot>> turnsStream = invitedTurns.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('turns')
                .where(FieldPath.documentId, whereIn: invitedTurns)
                .snapshots()
                .map((snapshot) {
                AppLogger.debug("Fetched ${snapshot.docs.length} Turns");
                return snapshot.docs;
              });

        return Rx.combineLatest2(
          cfqsStream,
          turnsStream,
          (List<DocumentSnapshot> cfqs, List<DocumentSnapshot> turns) {
            List<DocumentSnapshot> allEvents = [...cfqs, ...turns];
            AppLogger.debug(
                "Combined events: ${allEvents.length} (${cfqs.length} CFQs + ${turns.length} Turns)");

            allEvents.sort((a, b) {
              DateTime dateA = getPublishedDateTime(a);
              DateTime dateB = getPublishedDateTime(b);
              return dateB.compareTo(dateA);
            });

            AppLogger.debug(
                "Events sorted. First event date: ${getEventDateTime(allEvents.first)}, Last event date: ${getEventDateTime(allEvents.last)}");
            return allEvents;
          },
        );
      });
    } catch (error) {
      AppLogger.error("Error in fetchCombinedEvents: $error");
      return Stream.value([]);
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

  // Private methods
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(searchController.text);
    });
  }

  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);

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

  void _listenToUserChanges() {
    _userSubscription = _firestore
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentUser = model.User.fromSnap(snapshot);

        // Update notifications count
        _unreadNotificationsCountSubject
            .add(_currentUser?.unreadNotificationsCount ?? 0);

        // Update conversations count
        final unreadConversationsCount = _currentUser?.conversations
                .where((conv) => conv.unreadMessagesCount > 0)
                .length ??
            0;
        _unreadConversationsCountSubject.add(unreadConversationsCount);

        notifyListeners();
      }
    });
  }

  Future<void> loadConversations() async {
    _conversations =
        await _conversationService.getUserConversations(currentUserUid);
    _sortConversations();
    _filteredConversations = _conversations;
    notifyListeners();
  }

  void _sortConversations() {
    _conversations.sort(
        (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
  }

  void searchConversations(String query) {
    _filteredConversations = _conversations
        .where((conversation) =>
            conversation.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> addConversationToUserList(String channelId) async {
    await _conversationService.addConversationToUser(currentUserUid, channelId);
    await loadConversations();
    notifyListeners();
  }

  Future<void> removeConversationFromUserList(String channelId) async {
    await _conversationService.removeConversationFromUser(
        currentUserUid, channelId);
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

  Future<void> toggleFollowUp(String cfqId, String userId) async {
    try {
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> data = cfqSnapshot.data() as Map<String, dynamic>;
      List<dynamic> followingUp = data['followingUp'] ?? [];

      // Get organizer's notification channel ID
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('users').doc(data['uid'] as String).get();
      String organizerNotificationChannelId = (organizerSnapshot.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      if (followingUp.contains(userId)) {
        await removeFollowUp(cfqId, userId);
      } else {
        await addFollowUp(cfqId, userId);
        // Create notification only when following up, not when removing
        await _createFollowUpNotification(
          cfqId,
          data['cfqName'] as String,
          organizerNotificationChannelId,
        );
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
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
        'type': notificationModel.NotificationType.attending
            .toString()
            .split('.')
            .last,
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

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final batch = _firestore.batch();
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(currentUser!.uid);

      final turnDoc = await turnRef.get();
      final userDoc = await userRef.get();

      if (!turnDoc.exists || !userDoc.exists) {
        throw Exception('Turn or User document does not exist');
      }

      final turnData = turnDoc.data()!;
      final userData = userDoc.data()!;

      // Remove user from all lists first
      final List<String> attending =
          List<String>.from(turnData['attending'] ?? []);
      final List<String> notAttending =
          List<String>.from(turnData['notAttending'] ?? []);
      final List<String> notSureAttending =
          List<String>.from(turnData['notSureAttending'] ?? []);

      attending.remove(currentUser!.uid);
      notAttending.remove(currentUser!.uid);
      notSureAttending.remove(currentUser!.uid);

      // Add user to appropriate list
      switch (status) {
        case 'attending':
          attending.add(currentUser!.uid);
          break;
        case 'notAttending':
          notAttending.add(currentUser!.uid);
          break;
        case 'notSureAttending':
          notSureAttending.add(currentUser!.uid);
          break;
      }

      // Update turn document
      batch.update(turnRef, {
        'attending': attending,
        'notAttending': notAttending,
        'notSureAttending': notSureAttending,
      });

      // Update user's attending status
      Map<String, dynamic> attendingStatus =
          Map<String, dynamic>.from(userData['attendingStatus'] ?? {});
      attendingStatus[turnId] = status;
      batch.update(userRef, {'attendingStatus': attendingStatus});

      await batch.commit();

      // Create notification if attending
      if (status == 'attending') {
        await _createAttendingNotification(turnId);
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating attending status: $e');
    }
  }

  Stream<String> attendingStatusStream(String turnId, String userId) {
    return _firestore
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

  void clearSearchString() {
    searchController.clear();
    _users = [];
    notifyListeners();
  }

  void clearSearchResults() {
    _users = [];
    notifyListeners();
  }

  Future<void> _createFollowUpNotification(
    String cfqId,
    String cfqName,
    String organizerNotificationChannelId,
  ) async {
    try {
      if (_currentUser == null) return;

      // Get the CFQ document to get the organizer's ID
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      String organizerId =
          (cfqSnapshot.data() as Map<String, dynamic>)['uid'] as String;

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.followUp
            .toString()
            .split('.')
            .last,
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

      // Increment unread notifications count for the organizer using their user ID
      await _firestore.collection('users').doc(organizerId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating follow-up notification: $e');
    }
  }
}
