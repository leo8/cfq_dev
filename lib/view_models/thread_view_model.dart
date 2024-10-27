import 'dart:async';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import '../providers/conversation_service.dart';

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
          return Stream.value(<DocumentSnapshot>[]);
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final invitedCfqs = List<String>.from(userData['invitedCfqs'] ?? []);
        final invitedTurns = List<String>.from(userData['invitedTurns'] ?? []);

        // Handle empty lists
        Stream<List<DocumentSnapshot>> cfqsStream = invitedCfqs.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('cfqs')
                .where(FieldPath.documentId, whereIn: invitedCfqs)
                .snapshots()
                .map((snapshot) => snapshot.docs);

        Stream<List<DocumentSnapshot>> turnsStream = invitedTurns.isEmpty
            ? Stream.value(<DocumentSnapshot>[])
            : FirebaseFirestore.instance
                .collection('turns')
                .where(FieldPath.documentId, whereIn: invitedTurns)
                .snapshots()
                .map((snapshot) => snapshot.docs);

        return Rx.combineLatest2(
          cfqsStream,
          turnsStream,
          (List<DocumentSnapshot> cfqs, List<DocumentSnapshot> turns) {
            List<DocumentSnapshot> allEvents = [...cfqs, ...turns];
            allEvents.sort((a, b) {
              DateTime dateA = getEventDateTime(a);
              DateTime dateB = getEventDateTime(b);
              return dateB.compareTo(dateA);
            });
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
    if (doc.reference.parent.id == 'turns') {
      return parseDate(data['eventDateTime']);
    } else {
      return data['eventDateTime'] != null
          ? parseDate(data['eventDateTime'])
          : parseDate(data['datePublished']);
    }
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
        final userData = snapshot.data() as Map<String, dynamic>;
        final updatedConversations = (userData['conversations']
                    as List<dynamic>?)
                ?.map((e) =>
                    model.ConversationInfo.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

        currentUser!.conversations.clear();
        currentUser!.conversations.addAll(updatedConversations);

        // Calculate and update unread conversations count
        int unreadCount = updatedConversations
            .where((conv) => conv.unreadMessagesCount > 0)
            .length;
        _unreadConversationsCountSubject.add(unreadCount);

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

  Future<void> updateAttendingStatus(String turnId, String status) async {
    try {
      final turnRef = _firestore.collection('turns').doc(turnId);
      final userRef = _firestore.collection('users').doc(currentUserUid);

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
                .where((id) => id != currentUserUid)
                .toList();
          }
        });

        // Add user to the appropriate list
        if (status != 'notAnswered') {
          turnData[status] = [...(turnData[status] ?? []), currentUserUid];
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

  void clearSearchString() {
    searchController.clear();
    _users = [];
    notifyListeners();
  }

  void clearSearchResults() {
    _users = [];
    notifyListeners();
  }
}
