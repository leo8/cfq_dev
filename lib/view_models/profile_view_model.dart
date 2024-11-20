import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../providers/storage_methods.dart';
import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';
import '../providers/conversation_service.dart';
import '../models/conversation.dart';
import 'package:uuid/uuid.dart';
import '../models/notification.dart' as notificationModel;
import '../view_models/requests_view_model.dart';
import 'dart:async';
import '../utils/styles/string.dart';

class ProfileViewModel extends ChangeNotifier {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;
  model.User? _user; // Profile user's data
  model.User? _currentUser; // Current user's data
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  model.User? get user => _user;
  bool _isCurrentUser = false;
  bool get isCurrentUser => _isCurrentUser;
  bool _isFriend = false; // Indicates if the profile user is a friend
  bool get isFriend => _isFriend;

  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  List<Conversation> get filteredConversations => _filteredConversations;

  List<String> _filteredCfqs = [];
  List<String> get filteredCfqs => _filteredCfqs;

  List<String> _filteredTurns = [];
  List<String> get filteredTurns => _filteredTurns;

  // Status variables for UI feedback
  bool _friendAdded = false;
  bool get friendAdded => _friendAdded;

  model.User? get currentUser => _currentUser;

  bool _friendRemoved = false;
  bool get friendRemoved => _friendRemoved;

  Stream<DocumentSnapshot>? _userStream;
  Stream<DocumentSnapshot>? get userStream => _userStream;

  int _commonFriendsCount = 0;
  int get commonFriendsCount => _commonFriendsCount;

  int _commonTeamsCount = 0;
  int get commonTeamsCount => _commonTeamsCount;

  String? _friendRequestStatus;
  String? get friendRequestStatus => _friendRequestStatus;

  String? _incomingRequestId;
  bool _hasIncomingRequest = false;

  bool get hasIncomingRequest => _hasIncomingRequest;

  StreamSubscription<DocumentSnapshot>? _userSubscription;
  bool _disposed = false;

  List<String> _userNames = [];
  List<String> get userNames => _userNames;

  @override
  void dispose() {
    _disposed = true;
    _userSubscription?.cancel();
    super.dispose();
  }

  ProfileViewModel({this.userId}) {
    fetchUserData();
    fetchUserNames();
  }

  Future<void> fetchUserData() async {
    try {
      // Get current user's UID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Determine which user profile to display
      String profileUserId = userId ?? currentUserId;

      // Fetch profile user's data
      model.User userData =
          await AuthMethods().getUserDetailsById(profileUserId);

      // Set up real-time listener for current user
      if (profileUserId != currentUserId) {
        _currentUser = await AuthMethods().getUserDetailsById(currentUserId);

        // Cancel existing subscription if any
        await _userSubscription?.cancel();

        // Add real-time listener for current user
        _userSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots()
            .listen((snapshot) {
          if (!_disposed && snapshot.exists) {
            final userData = snapshot.data() as Map<String, dynamic>;
            if (_currentUser != null) {
              _currentUser!.favorites.clear();
              _currentUser!.favorites
                  .addAll(List<String>.from(userData['favorites'] ?? []));
              _currentUser =
                  model.User.fromSnap(snapshot); // Update entire user object
              _isFriend = _currentUser!.friends.contains(_user!.uid);
              if (!_disposed) {
                checkFriendRequestStatus(); // This will trigger UI updates via notifyListeners()
              }
            }
            if (!_disposed) {
              notifyListeners();
            }
          }
        });
      } else {
        _currentUser = userData; // Viewing own profile
        // Add real-time listener for own profile
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final userData = snapshot.data() as Map<String, dynamic>;
            if (_currentUser != null) {
              _currentUser!.favorites.clear();
              _currentUser!.favorites
                  .addAll(List<String>.from(userData['favorites'] ?? []));
            }
            notifyListeners();
          }
        });
      }

      _user = userData;
      _isCurrentUser = (profileUserId == currentUserId);

      if (!_isCurrentUser) {
        _isFriend = _currentUser!.friends.contains(profileUserId);

        // Calculate common friends
        _commonFriendsCount = _currentUser!.friends
            .where((friendId) => _user!.friends.contains(friendId))
            .length;

        // Calculate common teams
        _commonTeamsCount = _currentUser!.teams
            .where((teamId) => _user!.teams.contains(teamId))
            .length;
      }

      await checkFriendRequestStatus();

      _isLoading = false;

      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(profileUserId)
          .snapshots();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLogger.error(e.toString());
    }
  }

  Future<void> fetchUserNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      _userNames = snapshot.docs.map((doc) {
        return doc['searchKey'] as String;
      }).toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error("Error fetching usernames: $e");
    }
  }

  /// Adds the profile user as a friend
  Future<void> addFriend({required VoidCallback onSuccess}) async {
    if (_isCurrentUser || _isFriend) {
      AppLogger.debug(
          'Skipping add friend: isCurrentUser=$_isCurrentUser, isFriend=$_isFriend');
      return;
    }

    try {
      AppLogger.debug(
          'Adding friend request from ${_currentUser!.uid} to ${_user!.uid}');

      final request = model.Request(
        id: const Uuid().v4(),
        type: model.RequestType.friend,
        requesterId: _currentUser!.uid,
        requesterUsername: _currentUser!.username,
        requesterProfilePictureUrl: _currentUser!.profilePictureUrl,
        timestamp: DateTime.now(),
        status: model.RequestStatus.pending,
      );

      AppLogger.debug('Created request: ${request.toJson()}');

      // Add request to receiver's requests
      await _firestore.collection('users').doc(_user!.uid).update({
        'requests': FieldValue.arrayUnion([request.toJson()]),
      });
      AppLogger.debug('Added request to receiver\'s requests');

      // Create notification
      await _createFriendRequestNotification();
      AppLogger.debug('Created friend request notification');

      _friendRequestStatus = 'pending';
      notifyListeners();

      AppLogger.debug('Friend request successfully added');
      onSuccess();
    } catch (e) {
      AppLogger.error('Error adding friend request: $e');
      AppLogger.error('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _createFriendRequestNotification() async {
    try {
      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'friendRequest',
        'content': {
          'requesterId': _currentUser!.uid,
          'requesterUsername': _currentUser!.username,
          'requesterProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification to receiver's notification channel
      await _firestore
          .collection('notifications')
          .doc(_user!.notificationsChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count
      await _firestore.collection('users').doc(_user!.uid).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error creating friend request notification: $e');
    }
  }

  /// Removes the profile user from friends
  Future<void> removeFriend({required VoidCallback onSuccess}) async {
    if (_isCurrentUser || !_isFriend) return;

    try {
      // Get references to the user documents
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      DocumentReference viewedUserRef =
          FirebaseFirestore.instance.collection('users').doc(_user!.uid);

      // Update the friends lists atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove viewed user's ID from current user's friends list
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([_user!.uid])
      });

      // Remove current user's ID from viewed user's friends list
      batch.update(viewedUserRef, {
        'friends': FieldValue.arrayRemove([_currentUser!.uid])
      });

      // Commit the batch
      await batch.commit();

      // Update the local model.User objects
      _currentUser!.friends.remove(_user!.uid);
      _user!.friends.remove(_currentUser!.uid);

      // Update isFriend status
      _isFriend = false;

      // Set friendRemoved to true
      _friendRemoved = true;

      notifyListeners();

      // Call the success callback
      onSuccess();
    } catch (e) {
      AppLogger.error('Error removing friend: $e');
      // Optionally, handle the error
    }
  }

  // Reset the status variables after the UI has displayed the message
  void resetStatus() {
    _friendAdded = false;
    _friendRemoved = false;
    notifyListeners();
  }

  /// Updates the user's active status in Firestore.
  Future<void> updateIsActiveStatus(bool isActive) async {
    if (!_isCurrentUser) return;
    try {
      await AuthMethods().updateIsActiveStatus(isActive);
      _user!.isActive = isActive;
      notifyListeners();
    } catch (e) {
      AppLogger.error(e.toString());
    }
  }

  /// Logs out the current user.
  Future<void> logOut() async {
    if (!_isCurrentUser) return;
    await AuthMethods().logOutUser();
  }

  bool isUsernameAlreadyTaken(String username) {
    // Allow keeping the same username
    if (_user != null &&
        username.toLowerCase() == _user!.username.toLowerCase()) {
      return false;
    }
    return _userNames.contains(username.toLowerCase());
  }

  Future<void> updateUserProfile(String username, String location,
      DateTime? birthDate, Uint8List? image) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate username length
      if (username.length < 3 || username.length > 10) {
        throw Exception(CustomString.invalidUsernameLength);
      }

      // Check if username is taken (excluding current username)
      if (isUsernameAlreadyTaken(username)) {
        throw Exception(CustomString.usernameAlreadyTaken);
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'username': username,
        'location': location,
        'birthDate': birthDate?.toIso8601String(),
        'searchKey': username.toLowerCase(),
      });

      // Update local usernames list
      _userNames.remove(_user!.username.toLowerCase()); // Remove old username
      _userNames.add(username.toLowerCase()); // Add new username

      // Update local user object
      _user = model.User(
        username: username,
        email: _user!.email,
        uid: _user!.uid,
        friends: _user!.friends,
        teams: _user!.teams,
        profilePictureUrl: _user!.profilePictureUrl,
        location: location,
        birthDate: birthDate,
        isActive: _user!.isActive,
        searchKey: username.toLowerCase(),
        postedTurns: _user!.postedTurns,
        invitedTurns: _user!.invitedTurns,
        postedCfqs: _user!.postedCfqs,
        invitedCfqs: _user!.invitedCfqs,
        favorites: _user!.favorites,
        conversations: _user!.conversations,
        notificationsChannelId: _user!.notificationsChannelId,
        unreadNotificationsCount: _user!.unreadNotificationsCount,
        requests: _user!.requests,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfilePicture(Uint8List file) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload new profile picture to storage
      String profilePictureUrl = await StorageMethods()
          .uploadImageToStorage('profilePicture', file, false);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'profilePictureUrl': profilePictureUrl,
      });

      // Update local user object
      _user = model.User(
        username: _user!.username,
        email: _user!.email,
        uid: _user!.uid,
        friends: _user!.friends,
        teams: _user!.teams,
        profilePictureUrl: profilePictureUrl,
        location: _user!.location,
        birthDate: _user!.birthDate,
        isActive: _user!.isActive,
        searchKey: _user!.username.toLowerCase(),
        postedTurns: _user!.postedTurns,
        invitedTurns: _user!.invitedTurns,
        postedCfqs: _user!.postedCfqs,
        invitedCfqs: _user!.invitedCfqs,
        favorites: _user!.favorites,
        conversations: _user!.conversations,
        notificationsChannelId: _user!.notificationsChannelId,
        unreadNotificationsCount: _user!.unreadNotificationsCount,
        requests: _user!.requests,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error(e.toString());
      notifyListeners();
    }
  }

  // Add this helper method at the class level
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  /// Fetches both "turn" and "cfq" collections from Firestore for the user's posts,
  /// combines them into a single stream, and sorts them by date.
  Stream<List<DocumentSnapshot>> fetchUserPosts() {
    try {
      String targetUserId = userId ?? FirebaseAuth.instance.currentUser!.uid;

      if (!_isCurrentUser && !_isFriend) {
        return Stream.value([]);
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .snapshots()
          .switchMap((userSnapshot) {
        if (!userSnapshot.exists) {
          AppLogger.warning(
              "User document does not exist for uid: $targetUserId");
          return Stream.value(<DocumentSnapshot>[]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final postedCfqs = List<String>.from(userData['postedCfqs'] ?? []);
        final postedTurns = List<String>.from(userData['postedTurns'] ?? []);

        if (!_isCurrentUser) {
          // Get current user's invited events
          final currentUserInvitedCfqs =
              List<String>.from(_currentUser?.invitedCfqs ?? []);
          final currentUserInvitedTurns =
              List<String>.from(_currentUser?.invitedTurns ?? []);

          // Filter posted events to only include those where current user is invited
          _filteredCfqs = postedCfqs
              .where((cfqId) => currentUserInvitedCfqs.contains(cfqId))
              .toList();
          _filteredTurns = postedTurns
              .where((turnId) => currentUserInvitedTurns.contains(turnId))
              .toList();
        } else {
          _filteredCfqs = postedCfqs;
          _filteredTurns = postedTurns;
        }

        // Handle empty lists
        if (filteredCfqs.isEmpty && filteredTurns.isEmpty) {
          return Stream.value([]);
        }

        // Create streams for CFQs in batches
        final cfqStreams = _chunkList(filteredCfqs, 30).map((chunk) => chunk
                .isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: chunk)
                .snapshots()
                .map((snapshot) => snapshot.docs
                    .where((doc) => !isEventExpired(doc))
                    .toList()));

        // Create streams for Turns in batches
        final turnStreams = _chunkList(filteredTurns, 30).map((chunk) =>
            chunk.isEmpty
                ? Stream.value(<DocumentSnapshot>[])
                : FirebaseFirestore.instance
                    .collection('turns')
                    .where(FieldPath.documentId, whereIn: chunk)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .where((doc) => !isEventExpired(doc))
                        .toList()));

        // Combine all streams
        return Rx.combineLatest([...cfqStreams, ...turnStreams],
            (List<List<DocumentSnapshot>> results) {
          List<DocumentSnapshot> allEvents = results.expand((x) => x).toList();

          allEvents.sort((a, b) {
            DateTime dateA =
                parseDate((a.data() as Map<String, dynamic>)['datePublished']);
            DateTime dateB =
                parseDate((b.data() as Map<String, dynamic>)['datePublished']);
            return dateB.compareTo(dateA);
          });

          return allEvents;
        });
      });
    } catch (error) {
      AppLogger.error("Error in fetchUserPosts: $error");
      return Stream.value([]);
    }
  }

  Stream<List<DocumentSnapshot>> fetchAttendingEvents(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .switchMap((userSnapshot) {
        if (!userSnapshot.exists) {
          AppLogger.warning("User document does not exist for uid: $userId");
          return Stream.value(<DocumentSnapshot>[]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final invitedTurns = List<String>.from(userData['invitedTurns'] ?? []);

        // Handle empty lists
        if (invitedTurns.isEmpty) {
          return Stream.value([]);
        }

        // Create streams for Turns in batches
        final turnStreams = _chunkList(invitedTurns, 30).map((chunk) =>
            chunk.isEmpty
                ? Stream.value(<DocumentSnapshot>[])
                : FirebaseFirestore.instance
                    .collection('turns')
                    .where(FieldPath.documentId, whereIn: chunk)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                            .where((doc) => !isEventExpired(doc))
                            // Add filter for attending status
                            .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final attending =
                              List<String>.from(data['attending'] ?? []);
                          return attending.contains(userId);
                        }).toList()));

        // Combine all event streams
        Stream<List<DocumentSnapshot>> eventsStream = Rx.combineLatest(
            [...turnStreams], (List<List<DocumentSnapshot>> results) {
          List<DocumentSnapshot> allEvents = results.expand((x) => x).toList();
          return allEvents;
        });

        // Handle birthdays stream
        Stream<List<DocumentSnapshot>> birthdaysStream =
            userId == currentUser?.uid
                ? fetchBirthdayEvents(userId)
                : Stream.value([]);

        // Combine events and birthdays streams
        return Rx.combineLatest2(
          eventsStream,
          birthdaysStream,
          (List<DocumentSnapshot> events, List<DocumentSnapshot> birthdays) {
            List<DocumentSnapshot> allEvents = [...events, ...birthdays];
            allEvents.sort((a, b) {
              DateTime dateA = parseDate(
                  (a.data() as Map<String, dynamic>)['eventDateTime']);
              DateTime dateB = parseDate(
                  (b.data() as Map<String, dynamic>)['eventDateTime']);
              return dateA.compareTo(dateB);
            });
            return allEvents;
          },
        );
      });
    } catch (error) {
      AppLogger.error("Error in fetchAttendingEvents: $error");
      return Stream.value([]);
    }
  }

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date as DateTime: $date");
        return DateTime.now();
      }
    } else if (date is DateTime) {
      return date;
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now();
    }
  }

  // Add these methods from ThreadViewModel
  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);

      if (isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([eventId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
      }

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

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final batch = _firestore.batch();
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(_currentUser!.uid);

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

      attending.remove(_currentUser!.uid);
      notAttending.remove(_currentUser!.uid);
      notSureAttending.remove(_currentUser!.uid);

      // Add user to appropriate list only if not unselecting
      if (status != 'notAnswered') {
        switch (status) {
          case 'attending':
            attending.add(_currentUser!.uid);
            break;
          case 'notAttending':
            notAttending.add(_currentUser!.uid);
            break;
          case 'notSureAttending':
            notSureAttending.add(_currentUser!.uid);
            break;
        }
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
      if (status == 'notAnswered') {
        attendingStatus.remove(turnId);
      } else {
        attendingStatus[turnId] = status;
      }
      batch.update(userRef, {'attendingStatus': attendingStatus});

      await batch.commit();
      final organizerId = turnData['uid'] as String;

      // Create notification if attending
      if (status == 'attending' && organizerId != _currentUser!.uid) {
        await _createAttendingNotification(turnId);
      }

      String channelId = turnData['channelId'] as String;

      if (status == 'attending') {
        bool hasConversation =
            await _conversationService.isConversationInUserList(
          _currentUser!.uid,
          channelId,
        );

        if (!hasConversation) {
          await _conversationService.addConversationToUser(
            _currentUser!.uid,
            channelId,
          );
        }
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
      if ((data['attending'] as List?)?.contains(userId) ?? false) {
        return 'attending';
      }
      if ((data['notAttending'] as List?)?.contains(userId) ?? false) {
        return 'notAttending';
      }
      if ((data['notSureAttending'] as List?)?.contains(userId) ?? false) {
        return 'notSureAttending';
      }
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

  void searchConversations(String query) {
    _filteredConversations = _conversations
        .where((conversation) =>
            conversation.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
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

  Future<void> addFollowUp(String cfqId, String userId) async {
    try {
      await _firestore.collection('cfqs').doc(cfqId).update({
        'followingUp': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      AppLogger.error('Error adding follow-up: $e');
      rethrow;
    }
  }

  Future<void> removeFollowUp(String cfqId, String userId) async {
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
      String channelId = data['channelId'] as String;

      bool isNowFollowing = !followingUp.contains(userId);

      if (isNowFollowing) {
        await addFollowUp(cfqId, userId);
        await _createFollowUpNotification(cfqId);
        bool hasConversation =
            await _conversationService.isConversationInUserList(
          userId,
          channelId,
        );

        if (!hasConversation) {
          await _conversationService.addConversationToUser(
            userId,
            channelId,
          );
        }
      } else {
        await removeFollowUp(cfqId, userId);
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling follow-up: $e');
      rethrow;
    }
  }

  Future<bool> isConversationInUserList(String channelId) async {
    return await _conversationService.isConversationInUserList(
        currentUser!.uid, channelId);
  }

  Stream<bool> isFollowingUpStream(String cfqId, String userId) {
    return _firestore.collection('cfqs').doc(cfqId).snapshots().map((snapshot) {
      List<dynamic> followingUp = snapshot.data()?['followingUp'] ?? [];
      return followingUp.contains(userId);
    });
  }

  Stream<List<DocumentSnapshot>> fetchBirthdayEvents(String userId) {
    try {
      final now = DateTime.now();

      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .switchMap((userSnapshot) {
        if (!userSnapshot.exists) {
          return Stream.value([]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final List<String> friends =
            List<String>.from(userData['friends'] ?? []);

        if (friends.isEmpty) {
          return Stream.value([]);
        }

        return FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: friends)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final friendData = doc.data();
                if (friendData['birthDate'] == null) return null;

                final birthDate =
                    DateTime.parse(friendData['birthDate'].toString());
                final nextBirthday = DateTime(
                  now.year,
                  birthDate.month,
                  birthDate.day,
                );

                final relevantBirthday = nextBirthday.isBefore(now)
                    ? DateTime(now.year + 1, birthDate.month, birthDate.day)
                    : nextBirthday;

                final birthdayEvent = {
                  ...friendData,
                  'eventDateTime': relevantBirthday.toIso8601String(),
                  'isBirthday': true,
                  'type': 'birthday',
                };

                return doc.reference.parent
                    .doc(doc.id)
                    .withConverter(
                      fromFirestore: (snapshot, _) => birthdayEvent,
                      toFirestore: (data, _) => data as Map<String, dynamic>,
                    )
                    .get();
              })
              .whereType<Future<DocumentSnapshot>>()
              .toList();
        }).asyncMap((futures) => Future.wait(futures));
      });
    } catch (error) {
      AppLogger.error("Error in fetchBirthdayEvents: $error");
      return Stream.value([]);
    }
  }

  Future<void> _createFollowUpNotification(String cfqId) async {
    try {
      if (_currentUser == null) return;

      // Get the CFQ document to get the organizer's ID and following users
      DocumentSnapshot cfqSnapshot =
          await _firestore.collection('cfqs').doc(cfqId).get();
      Map<String, dynamic> cfqData = cfqSnapshot.data() as Map<String, dynamic>;
      List<String> followingUsers =
          List<String>.from(cfqData['followingUp'] ?? []);

      // Remove current user from notification recipients
      followingUsers.remove(_currentUser!.uid);

      if (followingUsers.isEmpty) return;

      // Create the base notification object
      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.followUp
            .toString()
            .split('.')
            .last,
        'content': {
          'cfqId': cfqId,
          'cfqName': cfqData['cfqName'] as String,
          'followerId': _currentUser!.uid,
          'followerUsername': _currentUser!.username,
          'followerProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Create a batch for all operations
      WriteBatch batch = _firestore.batch();

      // Get all following users' notification channels and create notifications
      QuerySnapshot userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followingUsers)
          .get();

      for (DocumentSnapshot userDoc in userDocs.docs) {
        String notificationChannelId =
            (userDoc.data() as Map<String, dynamic>)['notificationsChannelId'];

        // Add notification to user's notification channel
        DocumentReference notificationRef = _firestore
            .collection('notifications')
            .doc(notificationChannelId)
            .collection('userNotifications')
            .doc();

        batch.set(notificationRef, notification);

        // Increment unread notifications count
        DocumentReference userRef =
            _firestore.collection('users').doc(userDoc.id);
        batch.update(userRef, {
          'unreadNotificationsCount': FieldValue.increment(1),
        });
      }

      // Commit all operations
      await batch.commit();
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

  Future<void> checkFriendRequestStatus() async {
    if (_disposed) {
      AppLogger.debug('Skipping friend request check: ViewModel is disposed');
      return;
    }
    if (_isCurrentUser || _isFriend) {
      AppLogger.debug(
          'Skipping friend request check: isCurrentUser=$_isCurrentUser, isFriend=$_isFriend');
      return;
    }

    try {
      AppLogger.debug(
          'Checking friend request status between current user (${_currentUser!.uid}) and viewed user (${_user!.uid})');

      // Get current user's requests
      final currentUserDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      final currentUserRequests = model.User.fromSnap(currentUserDoc).requests;
      AppLogger.debug(
          'Current user has ${currentUserRequests.length} requests');

      // Get viewed user's requests
      final viewedUserDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      final viewedUserRequests = model.User.fromSnap(viewedUserDoc).requests;
      AppLogger.debug('Viewed user has ${viewedUserRequests.length} requests');

      // First check if there's an incoming request (from viewed user to current user)
      final incomingRequest = currentUserRequests.firstWhere(
        (r) =>
            r.type == model.RequestType.friend &&
            r.requesterId == _user!.uid &&
            r.status == model.RequestStatus.pending,
        orElse: () => model.Request.empty(),
      );

      // If no incoming request, check for outgoing request (from current user to viewed user)
      final outgoingRequest = incomingRequest.id.isEmpty
          ? viewedUserRequests.firstWhere(
              (r) =>
                  r.type == model.RequestType.friend &&
                  r.requesterId == _currentUser!.uid &&
                  r.status == model.RequestStatus.pending,
              orElse: () => model.Request.empty(),
            )
          : model.Request.empty();

      AppLogger.debug(
          'Incoming request found: ${incomingRequest.id.isNotEmpty}');
      if (incomingRequest.id.isNotEmpty) {
        AppLogger.debug('Incoming request status: ${incomingRequest.status}');
      }

      AppLogger.debug(
          'Outgoing request found: ${outgoingRequest.id.isNotEmpty}');
      if (outgoingRequest.id.isNotEmpty) {
        AppLogger.debug('Outgoing request status: ${outgoingRequest.status}');
      }

      if (incomingRequest.id.isNotEmpty) {
        _incomingRequestId = incomingRequest.id;
        _hasIncomingRequest = true;
        _friendRequestStatus =
            incomingRequest.status.toString().split('.').last;
        AppLogger.debug(
            'Set status from incoming request: $_friendRequestStatus, hasIncoming: $_hasIncomingRequest');
      } else if (outgoingRequest.id.isNotEmpty) {
        _friendRequestStatus =
            outgoingRequest.status.toString().split('.').last;
        _hasIncomingRequest = false;
        AppLogger.debug(
            'Set status from outgoing request: $_friendRequestStatus');
      } else {
        _friendRequestStatus = null;
        _hasIncomingRequest = false;
        AppLogger.debug('No requests found, cleared status');
      }

      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error checking friend request status: $e');
      AppLogger.error('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> acceptFriendRequest() async {
    if (_incomingRequestId == null) {
      AppLogger.debug('No incoming request ID found');
      return;
    }

    try {
      AppLogger.debug('Accepting friend request: $_incomingRequestId');
      AppLogger.debug(
          'Current user: ${_currentUser!.uid}, Requester: ${_user!.uid}');

      final requestsViewModel =
          RequestsViewModel(currentUserId: _currentUser!.uid);
      await requestsViewModel.acceptRequest(_incomingRequestId!);
      AppLogger.debug('Request accepted in RequestsViewModel');

      // Update local state immediately
      _isFriend = true;
      _hasIncomingRequest = false;
      _friendRequestStatus = null;
      _incomingRequestId = null;

      AppLogger.debug('Local state updated: isFriend=$_isFriend');

      // Create notification for requester
      await createAcceptedFriendRequestNotification(
        requesterId: _user!.uid,
      );

      notifyListeners(); // Trigger UI update immediately

      // Fetch latest data to ensure consistency
      await fetchUserData();
    } catch (e) {
      AppLogger.error('Error accepting friend request: $e');
      AppLogger.error('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> denyFriendRequest() async {
    if (_incomingRequestId == null) return;

    try {
      AppLogger.debug('Denying friend request: $_incomingRequestId');

      final requestsViewModel =
          RequestsViewModel(currentUserId: _currentUser!.uid);
      await requestsViewModel.denyRequest(_incomingRequestId!);

      // Update local state immediately
      _hasIncomingRequest = false;
      _friendRequestStatus = null;
      _incomingRequestId = null;

      AppLogger.debug('Local state cleared after denial');
      notifyListeners(); // Trigger UI update immediately

      // Fetch latest data to ensure consistency
      await fetchUserData();
    } catch (e) {
      AppLogger.error('Error denying friend request: $e');
      AppLogger.error('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> createAcceptedFriendRequestNotification({
    required String requesterId,
  }) async {
    try {
      if (_currentUser == null) return;

      // Get the requester's notification channel ID
      DocumentSnapshot requesterDoc =
          await _firestore.collection('users').doc(requesterId).get();
      String requesterNotificationChannelId = (requesterDoc.data()
          as Map<String, dynamic>)['notificationsChannelId'];

      final notification = {
        'id': const Uuid().v4(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': notificationModel.NotificationType.acceptedFriendRequest
            .toString()
            .split('.')
            .last,
        'content': {
          'accepterId': _currentUser!.uid,
          'accepterUsername': _currentUser!.username,
          'accepterProfilePictureUrl': _currentUser!.profilePictureUrl,
        },
      };

      // Add notification
      await _firestore
          .collection('notifications')
          .doc(requesterNotificationChannelId)
          .collection('userNotifications')
          .add(notification);

      // Increment unread notifications count
      await _firestore.collection('users').doc(requesterId).update({
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error(
          'Error creating accepted friend request notification: $e');
    }
  }

  bool isEventExpired(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isTurn = doc.reference.parent.id == 'turns';
    final DateTime now = DateTime.now();

    if (isTurn) {
      // Handle Turn expiration
      final DateTime? endDateTime =
          data['endDateTime'] != null ? parseDate(data['endDateTime']) : null;
      final DateTime eventDateTime = parseDate(data['eventDateTime']);

      if (endDateTime != null) {
        return now.isAfter(endDateTime.add(const Duration(hours: 12)));
      } else {
        return now.isAfter(eventDateTime.add(const Duration(hours: 24)));
      }
    } else {
      // Handle CFQ expiration
      final DateTime? endDateTime =
          data['endDateTime'] != null ? parseDate(data['endDateTime']) : null;
      final DateTime? eventDateTime = data['eventDateTime'] != null
          ? parseDate(data['eventDateTime'])
          : null;
      final DateTime publishedDateTime = parseDate(data['datePublished']);

      if (endDateTime != null) {
        return now.isAfter(endDateTime.add(const Duration(hours: 12)));
      } else if (eventDateTime != null) {
        return now.isAfter(eventDateTime.add(const Duration(hours: 24)));
      } else {
        return now.isAfter(publishedDateTime.add(const Duration(hours: 24)));
      }
    }
  }
}
