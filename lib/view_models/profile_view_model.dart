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

  ProfileViewModel({this.userId}) {
    fetchUserData();
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
        // Add real-time listener for current user
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

  /// Adds the profile user as a friend
  Future<void> addFriend({required VoidCallback onSuccess}) async {
    if (_isCurrentUser || _isFriend) return;

    try {
      // Get references to the user documents
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      DocumentReference viewedUserRef =
          FirebaseFirestore.instance.collection('users').doc(_user!.uid);

      // Update the friends lists atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add viewed user's ID to current user's friends list
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([_user!.uid])
      });

      // Add current user's ID to viewed user's friends list
      batch.update(viewedUserRef, {
        'friends': FieldValue.arrayUnion([_currentUser!.uid])
      });

      // Commit the batch
      await batch.commit();

      // Update the local model.User objects
      _currentUser!.friends.add(_user!.uid);
      _user!.friends.add(_currentUser!.uid);

      // Update isFriend status
      _isFriend = true;

      // Set friendAdded to true
      _friendAdded = true;

      notifyListeners();

      // Call the success callback
      onSuccess();
    } catch (e) {
      AppLogger.error('Error adding friend: $e');
      // Optionally, handle the error
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

  Future<void> updateUserProfile(
      String username, String location, DateTime? birthDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'username': username,
        'location': location,
        'birthDate': birthDate?.toIso8601String(),
      });

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
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error(e.toString());
      notifyListeners();
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
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error(e.toString());
      notifyListeners();
    }
  }

  /// Fetches both "turn" and "cfq" collections from Firestore for the user's posts,
  /// combines them into a single stream, and sorts them by date.
  Stream<List<DocumentSnapshot>> fetchUserPosts() {
    try {
      // Use the userId parameter if provided (friend's profile), otherwise use current user's ID
      String targetUserId = userId ?? FirebaseAuth.instance.currentUser!.uid;

      // Only fetch posts if viewing own profile or if the user is a friend
      if (!_isCurrentUser && !_isFriend) {
        return Stream.value([]); // Return empty stream for non-friends
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

        // Handle empty lists
        Stream<List<DocumentSnapshot>> cfqsStream = postedCfqs.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: postedCfqs)
                .snapshots()
                .map((snapshot) => snapshot.docs);

        Stream<List<DocumentSnapshot>> turnsStream = postedTurns.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('turns')
                .where(FieldPath.documentId, whereIn: postedTurns)
                .snapshots()
                .map((snapshot) => snapshot.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final invitees =
                          List<String>.from(data['invitees'] ?? []);
                      final organizers =
                          List<String>.from(data['organizers'] ?? []);
                      final currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;
                      return invitees.contains(currentUserId) ||
                          organizers.contains(currentUserId);
                    }).toList());

        return Rx.combineLatest2(
          cfqsStream,
          turnsStream,
          (List<DocumentSnapshot> cfqs, List<DocumentSnapshot> turns) {
            List<DocumentSnapshot> allEvents = [...cfqs, ...turns];
            allEvents.sort((a, b) {
              DateTime dateA = parseDate(
                  (a.data() as Map<String, dynamic>)['datePublished']);
              DateTime dateB = parseDate(
                  (b.data() as Map<String, dynamic>)['datePublished']);
              return dateB.compareTo(dateA);
            });
            return allEvents;
          },
        );
      });
    } catch (error) {
      AppLogger.error("Error in fetchUserPosts: $error");
      return Stream.value([]);
    }
  }

  Stream<List<DocumentSnapshot>> fetchAttendingEvents(String userId) {
    try {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      Stream<List<DocumentSnapshot>> turnsStream = FirebaseFirestore.instance
          .collection('turns')
          .where('attending', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.where((doc) {
          DateTime eventDate =
              parseDate((doc.data() as Map<String, dynamic>)['eventDateTime']);
          return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
        }).toList();
      });

      Stream<List<DocumentSnapshot>> birthdaysStream =
          userId == currentUser?.uid
              ? fetchBirthdayEvents(userId)
              : Stream.value([]);
      AppLogger.debug(birthdaysStream.toString());
      birthdaysStream = birthdaysStream.map((birthdays) {
        return birthdays;
      });
      return Rx.combineLatest2(
        turnsStream,
        birthdaysStream,
        (List<DocumentSnapshot> turns, List<DocumentSnapshot> birthdays) {
          List<DocumentSnapshot> allEvents = [...turns, ...birthdays];
          allEvents.sort((a, b) {
            DateTime dateA =
                parseDate((a.data() as Map<String, dynamic>)['eventDateTime']);

            DateTime dateB =
                parseDate((b.data() as Map<String, dynamic>)['eventDateTime']);

            return dateA.compareTo(dateB);
          });

          for (var e in allEvents) {
            final data = e.data() as Map<String, dynamic>;
            final date = e.reference.parent.id == 'turns'
                ? data['eventDateTime']
                : data['birthDate'];
            AppLogger.debug('Event date: $date');
          }
          return allEvents;
        },
      );
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

        transaction.update(turnRef, turnData);
        transaction.update(userRef, userData);
      });

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

      if (followingUp.contains(userId)) {
        await removeFollowUp(cfqId, userId);
      } else {
        await addFollowUp(cfqId, userId);
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
}
