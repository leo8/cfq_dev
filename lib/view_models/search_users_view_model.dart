import 'package:cfq_dev/models/user.dart' as model;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUsersViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  List<model.User> _users = [];
  List<model.User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SearchUsersViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    performSearch(searchController.text);
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
      print('Error while searching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
