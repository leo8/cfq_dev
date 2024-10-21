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
    super.dispose();
  }

  // Existing methods (performSearch, parseDate, fetchCombinedEvents)

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
    if (query.isEmpty) {
      _users = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Query Firestore for users matching the search query
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('searchKey', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('searchKey',
              isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .get();

      List<model.User> users =
          snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();

      _users = users.where((user) => user.uid != currentUserUid).toList();
    } catch (e) {
      AppLogger.error('Error while searching users: $e');
    }

    _isLoading = false;
    notifyListeners();
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
      // Fetch "turns" collection, sorted by datePublished in descending order
      Stream<QuerySnapshot> turnsStream = FirebaseFirestore.instance
          .collection('turns')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Fetch "cfqs" collection, sorted by datePublished in descending order
      Stream<QuerySnapshot> cfqsStream = FirebaseFirestore.instance
          .collection('cfqs')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Combine the two streams into one using Rx.combineLatest2 from rxdart
      return Rx.combineLatest2(turnsStream, cfqsStream,
          (QuerySnapshot turnsSnapshot, QuerySnapshot cfqsSnapshot) {
        // Log the number of documents retrieved from both snapshots
        AppLogger.info(
            "Turns snapshot docs count: ${turnsSnapshot.docs.length}");
        AppLogger.info("CFQs snapshot docs count: ${cfqsSnapshot.docs.length}");

        // Merge documents from both collections into a single list
        List<DocumentSnapshot> allDocs = [];
        allDocs.addAll(turnsSnapshot.docs);
        allDocs.addAll(cfqsSnapshot.docs);

        /// Helper function to retrieve the relevant date for sorting.
        /// Looks for 'eventDateTime' in 'turns' and 'datePublished' in 'cfqs'.
        DateTime getDate(DocumentSnapshot doc) {
          dynamic date;
          if (doc.reference.parent.id == 'turns') {
            date = doc['eventDateTime']; // Use eventDateTime for turns
          } else if (doc.reference.parent.id == 'cfqs') {
            date = doc['datePublished']; // Use datePublished for cfqs
          } else {
            date = DateTime.now(); // Fallback to the current date if unknown
          }
          return parseDate(date);
        }

        // Sort the combined events by their respective dates in descending order
        allDocs.sort((a, b) {
          try {
            DateTime dateTimeA = getDate(a);
            DateTime dateTimeB = getDate(b);
            return dateTimeB.compareTo(dateTimeA); // Sort by date descending
          } catch (error) {
            AppLogger.error("Error while sorting events: $error");
            return 0; // Avoid crashing on sorting errors
          }
        });

        // Log the total number of events after sorting
        AppLogger.info(
            "Total events after merging and sorting: ${allDocs.length}");
        return allDocs; // Return the sorted list of events
      });
    } catch (error) {
      AppLogger.error("Error in fetchCombinedEvents: $error");
      rethrow; // Rethrow the error to propagate it to the caller
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
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentUser = model.User.fromSnap(snapshot);
        _setupActiveFriendsStream(); // Update active friends stream when user changes
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

  bool isConversationInUserList(String channelId) {
    return _conversations.any((conversation) => conversation.id == channelId);
  }
}
