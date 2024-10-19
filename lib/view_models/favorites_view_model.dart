import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../utils/logger.dart';

class FavoritesViewModel extends ChangeNotifier {
  final String currentUserId;
  model.User? _currentUser;
  List<DocumentSnapshot> _favoriteEvents = [];
  bool _isLoading = true;

  FavoritesViewModel({required this.currentUserId}) {
    _initializeData();
  }

  model.User? get currentUser => _currentUser;

  List<DocumentSnapshot> get favoriteEvents => _favoriteEvents;
  bool get isLoading => _isLoading;

  Future<void> _initializeData() async {
    await _fetchCurrentUser();
    await _fetchFavoriteEvents();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      _currentUser = model.User.fromSnap(userSnap);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching current user: $e');
    }
  }

  Future<void> _fetchFavoriteEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null || _currentUser!.favorites.isEmpty) {
        _favoriteEvents = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      List<DocumentSnapshot> turns = await FirebaseFirestore.instance
          .collection('turns')
          .where('turnId', whereIn: _currentUser!.favorites)
          .get()
          .then((snapshot) => snapshot.docs);

      List<DocumentSnapshot> cfqs = await FirebaseFirestore.instance
          .collection('cfqs')
          .where('cfqId', whereIn: _currentUser!.favorites)
          .get()
          .then((snapshot) => snapshot.docs);

      _favoriteEvents = [...turns, ...cfqs];
      _favoriteEvents.sort((a, b) {
        DateTime dateA = (a['eventDateTime'] ?? a['datePublished']).toDate();
        DateTime dateB = (b['eventDateTime'] ?? b['datePublished']).toDate();
        return dateB.compareTo(dateA);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching favorite events: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      if (!isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([eventId])
        });
        _currentUser!.favorites.remove(eventId);
        _favoriteEvents.removeWhere(
            (event) => event['turnId'] == eventId || event['cfqId'] == eventId);
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e');
    }
  }
}
