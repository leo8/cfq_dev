import 'dart:async';

import 'package:cfq_dev/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user.dart' as model;

class ThreadViewModel extends ChangeNotifier {
  // Search functionality
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  List<model.User> _users = [];
  List<model.User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ThreadViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(searchController.text);
    });
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

      _users = users;
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
}
